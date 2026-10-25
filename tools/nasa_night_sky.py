#!/usr/bin/env python3
"""
Build Halcyon's night-sky assets from real astronomical data.

Inputs (download them yourself; they are not shipped with the pack):
  NASA SVS 4851 "Deep Star Maps 2020" (https://svs.gsfc.nasa.gov/4851),
  galactic plate carree, 16384x8192 OpenEXR:
    milkyway_2020_16k_gal.exr   unresolved Milky Way background (Gaia DR2
                                stars, without the Hipparcos/Tycho stars)
    hiptyc_2020_16k_gal.exr     Hipparcos-2 + Tycho-2 stars (bright layer)
  The Hipparcos Main Catalogue (ESA 1997), CDS VizieR I/239/hip_main, TSV
  with columns HIP RAICRS DEICRS Vmag B-V (V < 8.5 is enough):
    https://vizier.cds.unistra.fr/viz-bin/asu-tsv?-source=I/239/hip_main&-out=HIP&-out=RAICRS&-out=DEICRS&-out=Vmag&-out=B-V&-out.max=unlimited&Vmag=%3C8.5
  The Yale Bright Star Catalogue, 5th ed. (Hoffleit & Warren 1991), VizieR
  V/50, used only to fill naked-eye stars missing from Hipparcos:
    https://vizier.cds.unistra.fr/viz-bin/asu-tsv?-source=V/50/catalog&-out=HR&-out=HD&-out=RAJ2000&-out=DEJ2000&-out=Vmag&-out=B-V&-out.max=unlimited

Outputs (in --out, normally shaders/textures):
  milkyway_8k.png  8192x2048 } Milky Way background in galactic coordinates,
  milkyway_4k.png  4096x1024 } latitude-warped (see below), 8-bit encoded
  starCatalog.bin  RGBA32F, 1024 wide: colour LUT, cell headers, star entries

Requires Python 3 with numpy, Pillow and OpenEXR (pip install OpenEXR).

Milky Way: catalogue stars are cut out of the hiptyc layer and the rest is
added to the Gaia background, in units of magnitude-0 stars per steradian.
The SVS maps are stretched (not linear photometry), so stars.glsl scales the
Milky Way separately with MW_EXPOSURE.
Layout: u = 0.5 - l / 360, v = 0.5 + 0.5 asinh(b/b0) / asinh(90/b0), b0 = 20,
first row = south galactic pole. Each row is blurred along longitude to its
own vertical resolution.
Encoding: e = (L / L_MAX)^(1/MW_GAMMA), 8 bit. L_MAX and MW_GAMMA must match
stars.glsl.

Stars: equi-angular cube-map grid (CELLS x CELLS per face, ICRS). Each star is
listed in every cell its footprint can touch, brightest first.

Texel layout (RGBA32F, row-major, 1024 texels per row):
  [0, 256)                 colour LUT: linear sRGB of a blackbody, luminance 1,
                           log-spaced in temperature 2000..50000 K
  [256, 256 + 6*CELLS^2)   cell headers: (first entry, entry count, 0, 0)
  then                     entries: (x, y, z, magQ * 256 + colQ)
                           xyz = unit direction (ICRS), magQ = (V + 2) * 256
"""
import argparse
import math
import os
import struct
import sys

import numpy as np

STAR_LIMIT = 8.0
CELLS = 128
INSERT_RADIUS = 0.35
LUT_SIZE = 256
T_MIN, T_MAX = 2000.0, 50000.0
B0 = 20.0
MW_GAMMA = 2.4
ROW = 1024
STAR_ROWS = 260
MW_L_MAX = 4670.68

A_G = np.array([
    [-0.0548755604, -0.8734370902, -0.4838350155],
    [0.4941094279, -0.4448296300, 0.7469822445],
    [-0.8676661490, -0.1980763734, 0.4559837762],
])


def read_tsv(path):
    rows = []
    header = None
    for line in open(path, encoding="utf-8"):
        if line.startswith("#") or not line.strip():
            continue
        fields = line.rstrip("\n").split("\t")
        if header is None:
            header = [h.strip() for h in fields]
            continue
        if fields[0].startswith("-") or not fields[0].strip() or fields[0].strip() in ("deg", ""):
            continue
        rows.append(fields)
    return header, rows


def load_hipparcos(path):
    header, rows = read_tsv(path)
    out = []
    for f in rows:
        try:
            ra, de, v = float(f[1]), float(f[2]), float(f[3])
        except ValueError:
            continue
        bv = float(f[4]) if f[4].strip() else math.nan
        out.append((int(f[0]), ra, de, v, bv))
    return np.array(out, dtype=np.float64)


def sexa(s, hours):
    p = s.split()
    sign = -1.0 if p[0].startswith("-") else 1.0
    a = abs(float(p[0])) + float(p[1]) / 60.0 + float(p[2]) / 3600.0
    return sign * a * (15.0 if hours else 1.0)


def load_bsc(path):
    header, rows = read_tsv(path)
    out = []
    for f in rows:
        try:
            ra, de, v = sexa(f[2], True), sexa(f[3], False), float(f[4])
        except (ValueError, IndexError):
            continue
        bv = float(f[5]) if len(f) > 5 and f[5].strip() else math.nan
        out.append((int(f[0]), ra, de, v, bv))
    return np.array(out, dtype=np.float64)


def radec_to_vec(ra, de):
    ra, de = np.radians(ra), np.radians(de)
    return np.stack([np.cos(de) * np.cos(ra), np.cos(de) * np.sin(ra), np.sin(de)], -1)


def vec_to_lb(v):
    g = v @ A_G.T
    l = np.degrees(np.arctan2(g[..., 1], g[..., 0])) % 360.0
    b = np.degrees(np.arcsin(np.clip(g[..., 2], -1.0, 1.0)))
    return l, b


def bv_to_temperature(bv):
    bv = np.clip(np.where(np.isnan(bv), 0.6, bv), -0.4, 2.0)
    return 4600.0 * (1.0 / (0.92 * bv + 1.7) + 1.0 / (0.92 * bv + 0.62))


def cie_cmf(lam):
    def g(x, mu, s1, s2):
        s = np.where(x < mu, s1, s2)
        return np.exp(-0.5 * ((x - mu) / s) ** 2)
    x = 1.056 * g(lam, 599.8, 37.9, 31.0) + 0.362 * g(lam, 442.0, 16.0, 26.7) - 0.065 * g(lam, 501.1, 20.4, 26.2)
    y = 0.821 * g(lam, 568.8, 46.9, 40.5) + 0.286 * g(lam, 530.9, 16.3, 31.1)
    z = 1.217 * g(lam, 437.0, 11.8, 36.0) + 0.681 * g(lam, 459.0, 26.0, 13.8)
    return x, y, z


def blackbody_srgb(temp):
    lam = np.arange(380.0, 781.0, 2.0)
    xb, yb, zb = cie_cmf(lam)
    l_m = lam * 1e-9
    c1, c2 = 3.741771852e-16, 1.438776877e-2
    spec = c1 / (l_m[None, :] ** 5 * (np.exp(c2 / (l_m[None, :] * temp[:, None])) - 1.0))
    xyz = np.stack([(spec * xb).sum(1), (spec * yb).sum(1), (spec * zb).sum(1)], -1)
    m = np.array([[3.2404542, -1.5371385, -0.4985314],
                  [-0.9692660, 1.8760108, 0.0415560],
                  [0.0556434, -0.2040259, 1.0572252]])
    rgb = xyz @ m.T
    rgb = np.maximum(rgb, 0.0)
    lum = rgb @ np.array([0.2126, 0.7152, 0.0722])
    return rgb / lum[:, None]


def temperature_to_index(t):
    u = (np.log(t) - math.log(T_MIN)) / (math.log(T_MAX) - math.log(T_MIN))
    return np.clip(np.round(u * (LUT_SIZE - 1)), 0, LUT_SIZE - 1).astype(np.int64)


def load_exr(path):
    import OpenEXR
    with OpenEXR.File(path, separate_channels=True) as f:
        ch = f.channels()
        return np.stack([ch[c].pixels.astype(np.float32) for c in "RGB"], -1)


def map_xy(l, b, w, h):
    """16k SVS galactic map: l = 0 in the middle, increasing to the left."""
    lw = ((l + 180.0) % 360.0) - 180.0
    return (0.5 - lw / 360.0) * w - 0.5, (0.5 - b / 180.0) * h - 0.5


def splat_radius(v):
    return np.clip(3.0 + 1.2 * (7.0 - v), 3.0, 13.0)


def remove_stars(ht, l, b, v):
    h, w, _ = ht.shape
    x, y = map_xy(l, b, w, h)
    removed = 0.0
    for xi, yi, bi, vi in zip(x, y, b, v):
        r = splat_radius(vi)
        stretch = 1.0 / max(math.cos(math.radians(bi)), 0.02)
        ry = int(math.ceil(r))
        rx = int(math.ceil(r * stretch))
        y0, y1 = max(int(round(yi)) - ry, 0), min(int(round(yi)) + ry + 1, h)
        cols = (np.arange(int(round(xi)) - rx, int(round(xi)) + rx + 1)) % w
        rows = np.arange(y0, y1)
        dy = (rows - yi)[:, None]
        dx = ((cols - xi + w / 2) % w - w / 2)[None, :] / stretch
        mask = (dx * dx + dy * dy) <= r * r
        block = ht[rows[:, None], cols[None, :]]
        removed += float(block[mask].sum())
        block[mask] = 0.0
        ht[rows[:, None], cols[None, :]] = block
    return removed


def calibrate(ht, l, b, v):
    """k * cos(b): summed pixel value of a magnitude-0 star."""
    h, w, _ = ht.shape
    lum = ht.mean(-1)
    x, y = map_xy(l, b, w, h)
    ks = []
    for xi, yi, bi, vi in zip(x, y, b, v):
        if not (7.0 <= vi <= 8.5) or abs(bi) > 40.0:
            continue
        xi, yi = int(round(xi)), int(round(yi))
        cw = int(math.ceil(4 / math.cos(math.radians(bi))))
        if yi < 5 or yi >= h - 5 or xi - cw < 0 or xi + cw >= w:
            continue
        patch = lum[yi - 4:yi + 5, xi - cw:xi + cw + 1]
        if patch.max() >= 0.999:
            continue
        ks.append(patch.sum() / 10 ** (-0.4 * vi) * math.cos(math.radians(bi)))
    return float(np.median(ks)), len(ks)


def warp_v_to_b(v):
    a = math.asinh(90.0 / B0)
    return B0 * np.sinh((2.0 * v - 1.0) * a)


def resample(src, wt, ht_rows):
    """Area-average the 16k plate carree map into the warped wt x ht grid."""
    hs, ws, _ = src.shape
    edges = warp_v_to_b(np.arange(ht_rows + 1) / ht_rows)
    src_top = 90.0 - np.arange(hs) * 180.0 / hs
    fx = ws // wt
    out = np.zeros((ht_rows, wt, 3), np.float32)
    vres = np.diff(edges)
    for j in range(ht_rows):
        lo, hi = edges[j], edges[j + 1]
        r0 = max(int(math.floor((90.0 - hi) / 180.0 * hs)), 0)
        r1 = min(int(math.ceil((90.0 - lo) / 180.0 * hs)), hs)
        rows = np.arange(r0, r1)
        top, bot = src_top[rows], src_top[rows] - 180.0 / hs
        overlap = np.clip(np.minimum(top, hi) - np.maximum(bot, lo), 0.0, None)
        wgt = overlap * np.cos(np.radians(0.5 * (top + bot)))
        wgt /= wgt.sum()
        row = np.tensordot(wgt, src[r0:r1], axes=(0, 0))
        row = row.reshape(wt, fx, 3).mean(1)
        bc = 0.5 * (lo + hi)
        texel = 360.0 / wt * max(math.cos(math.radians(bc)), 1e-4)
        width = min(vres[j] / texel, float(wt))
        if width > 1.0:
            row = circular_box(row, width)
        out[j] = row
    return out


def circular_box(row, width):
    n = row.shape[0]
    c = np.concatenate([np.zeros((1, 3)), np.cumsum(np.concatenate([row, row, row]), 0)], 0)
    x = np.arange(n) + n + 0.5
    a, b = x - 0.5 * width, x + 0.5 * width

    def interp(t):
        i = np.floor(t).astype(np.int64)
        f = (t - i)[:, None]
        return c[i] * (1 - f) + c[np.minimum(i + 1, len(c) - 1)] * f
    return ((interp(b) - interp(a)) / width).astype(np.float32)


def save_png(path, img):
    from PIL import Image
    Image.fromarray(img, "RGB").save(path, optimize=True)


def cube_cell(d):
    """Equi-angular cube-map cell of unit vectors d (N,3); must match stars.glsl."""
    a = np.abs(d)
    axis = np.where(a[:, 0] > a[:, 1], np.where(a[:, 0] > a[:, 2], 0, 2), np.where(a[:, 1] > a[:, 2], 1, 2))
    major = d[np.arange(len(d)), axis]
    u = np.where(axis == 0, d[:, 1], d[:, 0])
    v = np.where(axis == 2, d[:, 1], d[:, 2])
    uv = np.stack([u, v], 1) / np.abs(major)[:, None]
    uv = np.arctan(uv) * (4.0 / math.pi)
    face = axis * 2 + (major > 0)
    cell = np.clip(np.floor((uv * 0.5 + 0.5) * CELLS), 0, CELLS - 1).astype(np.int64)
    return (face * CELLS + cell[:, 1]) * CELLS + cell[:, 0]


def build_catalog(dirs, mags, temps):
    n = len(dirs)
    order = np.argsort(mags, kind="stable")
    dirs, mags, temps = dirs[order], mags[order], temps[order]
    r = math.radians(INSERT_RADIUS)
    t1 = np.cross(dirs, np.where(np.abs(dirs[:, 2:3]) < 0.9, [[0, 0, 1]], [[1, 0, 0]]))
    t1 /= np.linalg.norm(t1, axis=1, keepdims=True)
    t2 = np.cross(dirs, t1)
    cells = [cube_cell(dirs)]
    for rad, count in ((r, 32), (0.5 * r, 12)):
        for k in range(count):
            ang = 2 * math.pi * k / count
            p = dirs + rad * (math.cos(ang) * t1 + math.sin(ang) * t2)
            cells.append(cube_cell(p / np.linalg.norm(p, axis=1, keepdims=True)))
    cells = np.stack(cells, 1)
    pairs = set()
    for i in range(n):
        for c in np.unique(cells[i]):
            pairs.add((int(c), i))
    pairs = sorted(pairs)
    ncell = 6 * CELLS * CELLS
    counts = np.zeros(ncell, np.int64)
    for c, _ in pairs:
        counts[c] += 1
    starts = np.concatenate([[0], np.cumsum(counts)[:-1]])
    entry_base = LUT_SIZE + ncell
    lut = blackbody_srgb(np.exp(np.linspace(math.log(T_MIN), math.log(T_MAX), LUT_SIZE)))
    total = entry_base + len(pairs)
    rows = (total + ROW - 1) // ROW
    if rows > STAR_ROWS:
        sys.exit(f"catalogue needs {rows} rows > STAR_ROWS {STAR_ROWS}: raise STAR_ROWS here and the "
                 f"starCatalog.bin height in shaders/shaders.properties together")
    rows = STAR_ROWS
    tex = np.zeros((rows * ROW, 4), np.float32)
    tex[:LUT_SIZE, :3] = lut
    tex[LUT_SIZE:entry_base, 0] = starts + entry_base
    tex[LUT_SIZE:entry_base, 1] = counts
    magq = np.clip(np.round((mags + 2.0) * 256.0), 0, 65535).astype(np.int64)
    colq = temperature_to_index(temps)
    for k, (c, i) in enumerate(pairs):
        tex[entry_base + k, :3] = dirs[i]
        tex[entry_base + k, 3] = float(magq[i] * 256 + colq[i])
    return tex.reshape(rows, ROW, 4), counts, len(pairs)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--milkyway", required=True)
    ap.add_argument("--hiptyc", required=True)
    ap.add_argument("--hipparcos", required=True)
    ap.add_argument("--bsc", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--preview", help="also write a small tone-mapped preview PNG here")
    args = ap.parse_args()

    hip = load_hipparcos(args.hipparcos)
    bsc = load_bsc(args.bsc)
    hip_dirs = radec_to_vec(hip[:, 1], hip[:, 2])
    keep = hip[:, 3] <= STAR_LIMIT
    bdirs = radec_to_vec(bsc[:, 1], bsc[:, 2])
    extra = []
    cos60 = math.cos(math.radians(60.0 / 3600.0))
    for i in range(len(bsc)):
        if not (hip_dirs @ bdirs[i] > cos60).any():
            extra.append(i)
    print(f"Hipparcos stars V<={STAR_LIMIT}: {keep.sum()}, Yale stars added: {len(extra)}"
          f" (HR {', '.join(str(int(bsc[i, 0])) for i in extra[:20])}{'...' if len(extra) > 20 else ''})")
    dirs = np.concatenate([hip_dirs[keep], bdirs[extra]])
    mags = np.concatenate([hip[keep, 3], bsc[extra, 3]])
    bvs = np.concatenate([hip[keep, 4], bsc[extra, 4]])
    temps = bv_to_temperature(bvs)
    l, b = vec_to_lb(dirs)

    print("loading EXR maps ...")
    ht = load_exr(args.hiptyc)
    k_cos, nk = calibrate(ht, l, b, mags)
    print(f"flux calibration: k*cos(b) = {k_cos:.2f} per magnitude-0 star ({nk} stars)")
    before = float(ht.sum())
    removed = remove_stars(ht, l, b, mags)
    print(f"hiptyc: removed {removed / before * 100:.1f}% of its light with the catalogue stars")
    lum = ht.mean(-1)
    mw = load_exr(args.milkyway)
    mw += ht
    del ht
    hs, ws, _ = mw.shape
    omega0 = 2.0 * math.pi * math.pi / (ws * hs)
    to_radiance = 1.0 / (omega0 * k_cos)

    peak_flux = 10 ** (-0.4 * (STAR_LIMIT - 0.5)) * k_cos * 0.3
    print(f"residual pixels brighter than a V~{STAR_LIMIT - 0.5:.1f} star core: {(lum > peak_flux).sum()}")

    hi = resample(mw, 8192, 2048) * to_radiance
    lo = resample(mw, 4096, 1024) * to_radiance
    del mw
    y = hi @ np.array([0.2126, 0.7152, 0.0722])
    l_auto = float(np.percentile(y, 99.995)) * 1.5
    l_max = MW_L_MAX
    print(f"radiance (mag-0 stars / sr): median {np.median(y):.4g}, 99th {np.percentile(y, 99):.4g},"
          f" max {y.max():.4g}, encoding L_MAX {l_max:.6g} (data suggests {l_auto:.6g})")
    if abs(l_auto / l_max - 1.0) > 0.25:
        print("WARNING: the data's range moved; consider updating MW_L_MAX here and in stars.glsl together")
    rows_deg = int(1.0 / (warp_v_to_b(np.array([1025 / 2048]))[0] - warp_v_to_b(np.array([1024 / 2048]))[0]))
    band = y[1024 - 4 * rows_deg:1024 + 4 * rows_deg]
    cs = np.cumsum(np.cumsum(np.pad(band, ((1, 0), (1, 0))), 0), 1)
    nx = int(8192 / 360)
    box = (cs[rows_deg:, nx:] - cs[:-rows_deg, nx:] - cs[rows_deg:, :-nx] + cs[:-rows_deg, :-nx]) / (rows_deg * nx)
    best = float(box.max())
    sb = -2.5 * math.log10(best / (180 / math.pi * 3600) ** 2)
    print(f"brightest 1-degree box: {best:.4g} mag-0/sr = {sb:.2f} mag/arcsec^2")

    os.makedirs(args.out, exist_ok=True)
    for name, img in (("milkyway_8k.png", hi), ("milkyway_4k.png", lo)):
        enc = np.clip(img / l_max, 0.0, 1.0) ** (1.0 / MW_GAMMA)
        save_png(os.path.join(args.out, name), (enc * 255.0 + 0.5).astype(np.uint8))
        print(f"wrote {name} {img.shape[1]}x{img.shape[0]}")
    if args.preview:
        p = lo[::2, ::2]
        p = p / (np.percentile(p, 99.5) + 1e-9)
        p = (np.clip(p / (1 + p), 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)
        save_png(args.preview, p)

    tex, counts, nentries = build_catalog(dirs, mags, temps)
    with open(os.path.join(args.out, "starCatalog.bin"), "wb") as f:
        f.write(tex.astype("<f4").tobytes())
    print(f"starCatalog.bin: {tex.shape[1]}x{tex.shape[0]} RGBA32F, {len(dirs)} stars, {nentries} entries,"
          f" cells used {np.count_nonzero(counts)}/{len(counts)}, max per cell {counts.max()},"
          f" mean per used cell {counts[counts > 0].mean():.2f}")
    print("\nshader constants (stars.glsl):")
    print(f"  MW_L_MAX {l_max:.6g}   MW_GAMMA {MW_GAMMA}   B0 {B0}   CELLS {CELLS}")
    print(f"  catalogue rows {tex.shape[0]}  (customTexture height)")


if __name__ == "__main__":
    sys.exit(main())
