# Chip art: Calvin in Metal4

The tile carries a Metal4-only picture in its upper-right corner: Calvin
(the author's avatar, `Calvin.png`), 36 x 57 um, in the channel between
two PDN stripe pairs over the right end of the top-right CFGMEM macro.
Nothing electrical: floating metal that the routers were kept off.

## How it is made

`tools/chip_art.py` turns a bitmap into a GDS cell on a pixel grid, with
the Metal4 rules met by construction (run inside the LibreLane nix shell):

```
python tools/chip_art.py --image Calvin.png \
    --box 1634.9 648.8 1670.9 705.5 --extent 1619.3 648.8 1686.9 705.5 \
    --clearance 0.6 --exclude 1662.61 634.47 1662.81 657.87 --out macros/CALVIN
```

- **Rendering.** The avatar's light disc becomes a metal plate and its ink
  strokes become slots in the plate, so under a microscope it reads as the
  avatar does: a bright disc with dark line art.  `--mode ink` draws the
  strokes as metal instead.
- **Pixels.** 0.6 um squares.  On that grid every width and every gap is a
  multiple of 0.6 um, which satisfies the sg13cmos5l Metal4 rules M4.a
  (width 0.20), M4.b (space / notch 0.21), M4.e (0.24 between lines wider
  than 0.39 um over a 1 um run) and M4.f (0.6 between lines wider than
  10 um over a 10 um run).  A clean-up pass fills every 2 x 2 checkerboard
  so no two metal pixels touch only at a corner (zero spacing to a
  checker).  The tool re-checks width, space, area and the wide-metal
  spacing on the merged shapes and refuses to write a cell that fails.
- **Extent and box.** `--extent` is where the whole image goes, `--box`
  the window actually drawn.  The disc is 57 um across but the channel
  between PDN pairs 9 and 10 is 36 um wide, so the disc is drawn larger
  than the window and clipped to it: the stripes frame the face instead
  of crossing it.  A two-pitch box put a stripe pair straight through the
  face; a disc that fits one channel was too coarse to read.
- **Keep-outs.** `--exclude` rectangles (die coordinates), grown by
  `--clearance`, are left empty: here the CFGMEM's route-through pin
  WROW[9] where it reaches into the window.  The box edges keep 0.6 um
  from the two stripe pairs.
- **Output.** `tt_um_pettit_calvin.gds` (Metal4 50/0 and Metal4.nofill
  50/23 over the box, so the chip-level fill leaves the dark areas
  alone; precheck lists both layers as valid), a LEF for the record,
  `art.json` for the flow step, `preview.png`.
- **Rectangles, not merged polygons.** The metal is written as one
  rectangle per horizontal run of pixels (392 of them).  A merged plate
  has holes (the eyes inside the face), and GDS can only write a polygon
  with holes as a boundary with cut lines, which visits the same vertices
  twice.  Tiny Tapeout's 3D viewer triangulates with CDT, which throws on
  such a polygon (an uncaught wasm exception, the viewer shows nothing),
  as the first version of this art demonstrated.  Rectangles have no
  holes; the DRC merges touching shapes before it checks, so it sees the
  same geometry.

## How it gets into the tile

The art is not a LibreLane macro.  A macro over the CFGMEM would overlap
a fixed macro, and its Metal4 obstruction would make pdngen cut the
stripes that cross it.  Instead:

1. `ROUTING_OBSTRUCTIONS` gets a Metal4 entry for the box (the
   `routing_obstruction` of art.json), so the tile's router never uses
   Metal4 there.  The CFGMEM pins under the box are reachable elsewhere
   (WROW[9] has a hundred other shapes) or from Metal3.
2. `Project.ChipArt` (librelane_plugin_prism_pdn.py), inserted with
   `"+Magic.WriteLEF": "Project.ChipArt"`, merges the cell into every GDS
   view after stream-out (GDS, KLAYOUT_GDS, MAG_GDS) at the die origin
   from art.json, and adds the box to the tile LEF as a Metal4 OBS so the
   Tiny Tapeout top-level router stays off it as well.  It runs before the
   KLayout DRC, which therefore checks the art in place.
3. Nothing changes in the ODB, DEF or netlist: LVS does not see the art.

`src/config_merged_art.json` is the vga3_anchor recipe with those three
additions and the registers anchored to vga3_anchor's own placement
(`tools/placements/vga3_anchor_placed_seq.json`).

## The corner, for the record

Die 1724.16 x 710.64 um.  The top-right CFGMEM_IHP16 sits at x 1346.39
to 1686.71, y 619.92 to 706.86.  Metal4 PDN pairs (VPWR 2.1 um, 3.52 um
gap, VGND 2.1 um) repeat every 44.96 um: pair 9 at 1626.54 to 1634.26,
pair 10 at 1671.50 to 1679.22, then the irregular last pair at 1703.91
(VGND) and 1716.46 (VPWR).  The CFGMEM's own Metal4 is its data-pin
stubs along the bottom edge (y below 629.3) and the route-through pin
WROW[9], 133 shapes spread over the macro, four of them near the window.
