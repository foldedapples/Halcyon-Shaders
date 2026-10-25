"""Split Halcyon into 'only what was added on top of Glimmer'.
usage: python3 -I extract.py HALCYON_DIR GLIMMER_GIT_DIR GLIMMER_COMMIT OUT_DIR
"""
import sys, os, re, subprocess, difflib, shutil, json

H, G, C, OUT = sys.argv[1:5]

def glimmer(path):
    r = subprocess.run(['git', '-C', G, 'show', f'{C}:{path}'], capture_output=True)
    return r.stdout if r.returncode == 0 else None

def kind(path):
    if path.endswith(('.properties', '.lang')): return 'props'
    if path.endswith(('.glsl', '.fsh', '.vsh', '.csh', '.gsh', '.tcs', '.tes')): return 'glsl'
    if path.endswith('.json'): return 'json'
    return 'other'

def normalise(lines, k):
    """code-only view of each line (comments/whitespace removed) -> list of (norm, original index)"""
    out = []
    in_block = False
    for i, l in enumerate(lines):
        s = l
        if k == 'glsl':
            res = ''
            j = 0
            while j < len(s):
                if in_block:
                    e = s.find('*/', j)
                    if e < 0: j = len(s); break
                    in_block = False; j = e + 2; continue
                if s.startswith('/*', j): in_block = True; j += 2; continue
                if s.startswith('//', j): break
                res += s[j]; j += 1
            s = res
        elif k == 'props':
            if s.lstrip().startswith('#') and not re.match(r'\s*#\s*(if|ifdef|ifndef|else|elif|endif|define|undef)\b', s):
                s = ''
        s = re.sub(r'\s+', ' ', s).strip()
        if s:
            out.append((s, i))
    return out

FUNC = re.compile(r'^[A-Za-z_][\w<>\[\]]*\s+([A-Za-z_]\w*)\s*\(')
def enclosing(lines, idx):
    for j in range(idx, -1, -1):
        m = FUNC.match(lines[j])
        if m and not lines[j].rstrip().endswith(';'):
            return m.group(1)
    return None

def walk(root):
    for r, _, fs in os.walk(root):
        for f in fs:
            p = os.path.join(r, f)
            yield os.path.relpath(p, H).replace(os.sep, '/')

report = {'new': [], 'glimmer_only': [], 'comment_only': [], 'mixed': {}, 'binary_changed': []}
os.makedirs(OUT, exist_ok=True)
integ_dir = os.path.join(OUT, 'integration')

for rel in sorted(walk(os.path.join(H, 'shaders'))):
    src = os.path.join(H, rel)
    b = open(src, 'rb').read()
    a = glimmer(rel)
    if a is None:
        dst = os.path.join(OUT, rel); os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst); report['new'].append(rel); continue
    if a == b:
        report['glimmer_only'].append(rel); continue
    k = kind(rel)
    try:
        al = a.decode('utf-8').splitlines(); bl = b.decode('utf-8').splitlines()
    except UnicodeDecodeError:
        report['binary_changed'].append(rel); continue
    if k == 'other':
        # plain text (licences etc.): keep only added lines
        add = [l for l in difflib.ndiff(al, bl) if l.startswith('+ ')]
        report['mixed'][rel] = [{'where': 'file', 'glimmer_lines': None, 'replaces': 0, 'code': [l[2:] for l in add]}]
        continue
    na = normalise(al, k if k != 'json' else 'glsl'); nb = normalise(bl, k if k != 'json' else 'glsl')
    sm = difflib.SequenceMatcher(a=[x[0] for x in na], b=[x[0] for x in nb], autojunk=False)
    hunks = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == 'equal': continue
        # Glimmer line range that this hunk replaces / sits next to (1-based, for lookup in upstream)
        if i2 > i1:
            gl = (na[i1][1] + 1, na[i2 - 1][1] + 1)
        else:
            gl = (na[i1 - 1][1] + 1 if i1 > 0 else 0, None)  # insertion after this Glimmer line
        if j2 > j1:
            start = nb[j1][1]; end = nb[j2 - 1][1]
            # pull in the comment lines directly above (the author's explanation)
            while start > 0 and bl[start - 1].strip().startswith(('//', '/*', '*', '#')) and (start - 1) not in [x[1] for x in nb]:
                start -= 1
            code = bl[start:end + 1]
        else:
            code = []
        hunks.append({
            'where': enclosing(bl, nb[j1][1] if j2 > j1 else (nb[j1 - 1][1] if j1 > 0 else 0)),
            'glimmer_lines': gl,
            'replaces': i2 - i1,
            'deleted_only': j2 == j1,
            'code': code,
        })
    if not hunks:
        report['comment_only'].append(rel)
    else:
        report['mixed'][rel] = hunks

# write integration notes
for rel, hunks in report['mixed'].items():
    p = os.path.join(integ_dir, rel + '.md')
    os.makedirs(os.path.dirname(p), exist_ok=True)
    lang = {'glsl': 'glsl', 'props': 'properties', 'json': 'json'}.get(kind(rel), '')
    with open(p, 'w') as f:
        f.write(f'# Halcyon changes to Glimmer file `{rel}`\n\n')
        f.write(f'Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to\n'
                f'Glimmer at commit `{C}` (github.com/jbritain/glimmer-shaders), so each change can be placed\n'
                f'back into that file, or recreated in a different base pipeline.\n\n')
        for n, h in enumerate(hunks, 1):
            gl = h['glimmer_lines']
            if gl is None: loc = 'whole file'
            elif gl[1] is None: loc = f'inserted after Glimmer line {gl[0]}'
            elif gl[0] == gl[1]: loc = f'replaces Glimmer line {gl[0]}'
            else: loc = f'replaces Glimmer lines {gl[0]}-{gl[1]}'
            fn = f' — in `{h["where"]}()`' if h.get('where') else ''
            if h.get('deleted_only'):
                f.write(f'## {n}. Removed Glimmer code ({loc}){fn}\n\nHalcyon deletes these Glimmer lines (no replacement).\n\n')
                continue
            f.write(f'## {n}. {loc}{fn}\n\n```{lang}\n' + '\n'.join(h['code']) + '\n```\n\n')

json.dump({k: (v if not isinstance(v, dict) else sorted(v)) for k, v in report.items()},
          open(os.path.join(OUT, 'extraction_report.json'), 'w'), indent=1)
print({k: len(v) for k, v in report.items()})
