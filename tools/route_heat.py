# Metal2/3/4 routing-demand heat map of the tile from a run's global-routing guides
# (after_grt.guide).  Usage, from the runs/ directory:  python3 ../tools/route_heat.py <run>
# Digits 0-9 = demand relative to the busiest bin, '#' = under a macro, bottom row = y 0.
import sys, glob, math
run = sys.argv[1]
W, H = 1724.16, 710.64
BX, BY = 28.736, 28.4256     # 60 x 25 bins
NX, NY = 60, 25
dem = {'Metal2': [[0.0]*NX for _ in range(NY)], 'Metal3': [[0.0]*NX for _ in range(NY)], 'Metal4': [[0.0]*NX for _ in range(NY)]}
f = glob.glob(f'{run}/4*-openroad-globalrouting/after_grt.guide')[0]
scale = 1000.0
with open(f) as fh:
    for line in fh:
        p = line.split()
        if len(p) != 5: continue
        x0, y0, x1, y1 = (float(v)/scale for v in p[:4]); L = p[4]
        if L not in dem: continue
        # spread the guide's length over the bins it covers (as wire length)
        horiz = (x1 - x0) >= (y1 - y0)
        if horiz:
            j = min(NY-1, int(((y0+y1)/2)/BY)); i0 = int(x0/BX); i1 = min(NX-1, int(x1/BX))
            for i in range(i0, i1+1):
                ox = min(x1, (i+1)*BX) - max(x0, i*BX)
                dem[L][j][i] += max(ox, 0)
        else:
            i = min(NX-1, int(((x0+x1)/2)/BX)); j0 = int(y0/BY); j1 = min(NY-1, int(y1/BY))
            for j in range(j0, j1+1):
                oy = min(y1, (j+1)*BY) - max(y0, j*BY)
                dem[L][j][i] += max(oy, 0)
# macro outlines from the run's resolved config (sizes by macro type)
import json, os
SIZES = {'CFGMEM': (331.2, 86.94), 'RM_IHPSG13_1P_512x32': (416.64, 191.34)}
macros = []
cfg = json.load(open(f'{run}/resolved.json')) if os.path.exists(f'{run}/resolved.json') else {}
for mname, m in cfg.get('MACROS', {}).items():
    w, h = next((v for k, v in SIZES.items() if mname.startswith(k)), (0, 0))
    for inst in m.get('instances', {}).values():
        x, y = inst['location']; macros.append((x, y, x + w, y + h))
def inmacro(cx, cy): return any(a<=cx<=c and b<=cy<=d for a,b,c,d in macros)
for L in ('Metal3', 'Metal2'):
    g = dem[L]; mx = max(max(r) for r in g)
    print(f"== {run} {L} demand (um of guide per bin, 0-9 = 0..{mx:.0f}), '#' = under a macro; bottom row = y 0")
    for j in range(NY-1, -1, -1):
        row = ''
        for i in range(NX):
            v = g[j][i]; cx, cy = (i+0.5)*BX, (j+0.5)*BY
            d = min(9, int(v / mx * 9.999))
            row += ('#' if inmacro(cx, cy) and d < 5 else str(d))
        print(f"{(j+1)*BY:6.0f} {row}")
    print('       ' + ''.join(str((i//10)%10) if i%10==0 else ' ' for i in range(NX)) + '  (x/100 um)')
    flat = sorted((v for r in g for v in r), reverse=True)
    print(f"   {L}: total {sum(flat)/1e6:.3f} M um, max bin {mx:.0f}, mean of top 20 bins {sum(flat[:20])/20:.0f}, bins >= 80% of max: {sum(1 for v in flat if v >= 0.8*mx)}")
