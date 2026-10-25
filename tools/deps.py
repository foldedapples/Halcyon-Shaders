"""List Glimmer-defined symbols that the kept Halcyon code still uses.
usage: python3 -I deps.py OUT_DIR GLIMMER_GIT_DIR COMMIT"""
import sys, os, re, subprocess, json
OUT, G, C = sys.argv[1:4]
files = subprocess.run(['git','-C',G,'ls-tree','-r','--name-only',C,'--','shaders'],capture_output=True,text=True).stdout.split()
FUNC = re.compile(r'^\s*(?:[A-Za-z_]\w*\s+)+([A-Za-z_]\w*)\s*\([^;]*$', re.M)
DEF = re.compile(r'^\s*#\s*define\s+([A-Za-z_]\w*)', re.M)
UNI = re.compile(r'^\s*uniform\s+\w+\s+([A-Za-z_]\w*)', re.M)
STRUCT = re.compile(r'\bstruct\s+([A-Za-z_]\w*)')
CONST = re.compile(r'^\s*const\s+\w+\s+([A-Za-z_]\w*)\s*=', re.M)
GLOBAL = re.compile(r'^(?:vec[234]|float|int|bool|mat[234])\s+([A-Za-z_]\w*)\s*=', re.M)
sym = {}
for f in files:
    if not f.endswith(('.glsl','.fsh','.vsh','.csh')): continue
    t = subprocess.run(['git','-C',G,'show',f'{C}:{f}'],capture_output=True,text=True).stdout
    for kind, rx in (('function',FUNC),('macro',DEF),('uniform',UNI),('struct',STRUCT),('const',CONST),('global',GLOBAL)):
        for m in rx.finditer(t):
            n = m.group(1)
            if n in ('main','if','for','while','return','else'): continue
            sym.setdefault(n, set()).add((kind, f))
# symbols the kept code defines itself
kept_text = ''
own = set()
for r,_,fs in os.walk(OUT):
    for fn in fs:
        if fn.endswith(('.glsl','.fsh','.vsh','.csh','.md')):
            t = open(os.path.join(r,fn), errors='ignore').read()
            kept_text += t + '\n'
            if not fn.endswith('.md'):
                for rx in (FUNC,DEF,UNI,STRUCT,CONST,GLOBAL):
                    own.update(m.group(1) for m in rx.finditer(t))
used = set(re.findall(r'\b[A-Za-z_]\w*\b', kept_text))
deps = {}
for n in sorted(used & set(sym)):
    if n in own and all(k!='function' for k,_ in sym[n]): continue
    for kind, f in sorted(sym[n]):
        deps.setdefault(f, set()).add(f'{n} ({kind})')
json.dump({f: sorted(v) for f, v in sorted(deps.items())}, open(os.path.join(OUT,'glimmer_dependencies.json'),'w'), indent=1)
print(len(deps), 'Glimmer files provide symbols used by Halcyon code')
for f,v in sorted(deps.items(), key=lambda x:-len(x[1]))[:15]: print(f, len(v))
