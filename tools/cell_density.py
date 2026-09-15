# Standard-cell utilization map of the tile per bin, from a placed .odb (e.g.
# runs/<run>/44-openroad-repairantennas/1-openroad-diodeinsertion/<design>.odb).
# Usage:  PATH=<nix devshell bin>:$PATH openroad -exit -no_splash -python tools/cell_density.py <odb>
import odb, sys
db = odb.dbDatabase.create(); odb.read_db(db, sys.argv[1])
blk = db.getChip().getBlock(); dbu = blk.getDbUnitsPerMicron()
BX, BY, NX, NY = 28.736, 28.4256, 60, 25
g = [[0.0]*NX for _ in range(NY)]
for inst in blk.getInsts():
    if inst.getMaster().isBlock(): continue
    bb = inst.getBBox(); x0,y0,x1,y1 = (v/dbu for v in (bb.xMin(),bb.yMin(),bb.xMax(),bb.yMax()))
    for j in range(int(y0/BY), min(NY-1,int(y1/BY))+1):
        for i in range(int(x0/BX), min(NX-1,int(x1/BX))+1):
            ox = min(x1,(i+1)*BX)-max(x0,i*BX); oy = min(y1,(j+1)*BY)-max(y0,j*BY)
            if ox>0 and oy>0: g[j][i] += ox*oy
macros = [(3.36,3.78,420.0,195.12),(3.36,340.2,420.0,531.54)] + [(x, y, x+331.2, y+86.94) for x in (537.11, 1346.39) for y in (3.78, 257.04, 366.66, 619.92)]
def inmacro(cx, cy): return any(a<=cx<=c and b<=cy<=d for a,b,c,d in macros)
print("== std-cell area utilization per bin (digit = tens of %, '#' = macro); bottom row = y 0")
for j in range(NY-1,-1,-1):
    row=''
    for i in range(NX):
        u = g[j][i]/(BX*BY); cx,cy=(i+0.5)*BX,(j+0.5)*BY
        row += '#' if inmacro(cx,cy) else str(min(9,int(u*10)))
    print(f"{(j+1)*BY:6.0f} {row}")
print('       ' + ''.join(str((i//10)%10) if i%10==0 else ' ' for i in range(NX)) + '  (x/100 um)')
# region summaries
def util(x0,y0,x1,y1):
    a=0; t=0
    for j in range(NY):
        for i in range(NX):
            cx,cy=(i+0.5)*BX,(j+0.5)*BY
            if x0<=cx<=x1 and y0<=cy<=y1 and not inmacro(cx,cy): a+=g[j][i]; t+=BX*BY
    return a/t*100 if t else 0
for name,r in [('top-left above SRAM1 (0-420, 535-711)',(0,535,420,711)),('left strip (420-537, 0-711)',(420,0,537,711)),('middle band (870-1340, 0-711)',(870,0,1340,711)),('top-middle (870-1340, 625-711)',(870,625,1340,711)),('corridor (0-420, 195-340)',(0,195,420,340)),('right strip (1680-1724)',(1680,0,1724,711))]:
    print(f"{name:42s} util {util(*r):5.1f}%")
