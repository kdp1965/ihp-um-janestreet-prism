#!/usr/bin/env python3
# Chip art: a bitmap into a Metal4-only GDS cell, on the pixel grid, with
# the DRC rules met by construction, plus the LEF obstruction and the
# routing keep-out that go with it.
#
#   python tools/chip_art.py --image Calvin.png --box 1635.3 648.8 1702.9 705.5 \
#       --exclude 1670.5 648.8 1680.2 705.5 ... --out macros/CALVIN
#
# runs inside the LibreLane nix shell (PIL, numpy, klayout.db).  Outputs in
# --out: <cell>.gds (Metal4 50/0 and Metal4.nofill 50/23, cell origin = the
# box's lower-left in die coordinates, so the cell is placed at (0, 0)),
# <cell>.lef (a MACRO with the box as a Metal4 OBS, for the record), art.json
# (what the Project.ChipArt flow step needs: the GDS, the cell, the box as
# the LEF obstruction to add to the tile) and preview.png.
#
# Rendering (--mode plate, the default): the picture's light areas inside its
# disc become a metal plate and its dark strokes become slots in the plate,
# so on silicon the avatar is a bright disc with dark line art.  --mode ink
# draws the strokes as metal instead.  Every pixel is --pixel um square
# (0.6 default): Metal4 width 0.2, space / notch 0.21, wide-metal spacing
# 0.24 (> 0.39 wide, 1 um run) and 0.6 (> 10 um wide, 10 um run) are all met
# on that grid, and the checkerboard clean-up removes corner-only contacts.
# Exclusions (--exclude, die coordinates, e.g. PDN stripes and macro pins on
# Metal4 under the box) are grown by --clearance and every pixel they touch
# is left empty.
import argparse
import json
import math
import os

import numpy as np
from PIL import Image
import klayout.db as kdb

LAYER_METAL4 = (50, 0)
LAYER_NOFILL = (50, 23)
# the fill-exclusion markers of every layer that chip-level fill touches
# (sg13cmos5l.lyp; precheck lists them all as valid): --nofill all
NOFILL_ALL = {"Activ": (1, 23), "GatPoly": (5, 23), "Metal1": (8, 23), "Metal2": (10, 23), "Metal3": (30, 23), "Metal4": (50, 23)}


def load_mask_gds(path, w_px, h_px, pixel):
    """A hand-edited art cell back onto the pixel grid: the Metal4 (50/0) of
    the GDS's top cell, in cell coordinates (0, 0 = the box's lower-left), a
    pixel being metal when at least half of it is covered.  On-grid edits
    come back exactly; off-grid strays are snapped; the checkerboard
    clean-up then removes corner-only contacts.  Row 0 is the bottom."""
    ly = kdb.Layout()
    ly.read(path)
    reg = kdb.Region(ly.top_cell().begin_shapes_rec(ly.layer(*LAYER_METAL4)))
    reg.merge()
    px = int(round(pixel / ly.dbu))
    mask = np.zeros((h_px, w_px), bool)
    for y in range(h_px):
        for x in range(w_px):
            cell = kdb.Region(kdb.Box(x * px, y * px, (x + 1) * px, (y + 1) * px))
            mask[y, x] = (reg & cell).area() * 2 >= px * px
    return mask, (w_px / 2.0, h_px / 2.0, 0.0)


def load_mask(path, w_px, h_px, mode, threshold, disc):
    """The metal mask (h_px x w_px bools) from the image."""
    im = Image.open(path).convert("L")
    W, H = im.size
    g = np.asarray(im).astype(float)
    # the disc: the light region's extent in the source (a round avatar on a dark background)
    light = g > 200
    ys, xs = np.where(light)
    cx, cy = (xs.min() + xs.max()) / 2.0, (ys.min() + ys.max()) / 2.0
    r = max(xs.max() - xs.min(), ys.max() - ys.min()) / 2.0
    # outside the disc everything is background: paint it dark before resampling
    yy, xx = np.mgrid[0:H, 0:W]
    inside = (xx - cx) ** 2 + (yy - cy) ** 2 <= (r + 0.5) ** 2
    g2 = np.where(inside, g, 0.0)
    small = np.asarray(Image.fromarray(g2.astype(np.uint8)).resize((w_px, h_px), Image.LANCZOS)).astype(float)
    sx, sy = w_px / W, h_px / H
    gy, gx = np.mgrid[0:h_px, 0:w_px]
    # the disc in grid pixels, with the comparison done in source pixels
    inside_s = ((gx + 0.5) / sx - cx) ** 2 + ((gy + 0.5) / sy - cy) ** 2 <= (r + 0.5) ** 2 if disc else np.ones((h_px, w_px), bool)
    if mode == "plate":
        mask = (small >= threshold) & inside_s
    else:
        mask = (small < threshold) & inside_s
    return mask, (cx * sx, cy * sy, r * (sx + sy) / 2)


def clean(mask):
    """No two metal pixels touching only at a corner (space 0 to a DRC
    checker): fill the 2x2 checkerboards until none is left."""
    m = mask.copy()
    for _ in range(20):
        a, b, c, d = m[:-1, :-1], m[:-1, 1:], m[1:, :-1], m[1:, 1:]
        chk = (a & d & ~b & ~c) | (b & c & ~a & ~d)
        if not chk.any():
            break
        ys, xs = np.where(chk)
        for y, x in zip(ys, xs):
            m[y:y + 2, x:x + 2] = True
    return m


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True, help="the bitmap; or a .gds of a hand-edited art cell (its Metal4 is re-gridded, see load_mask_gds)")
    ap.add_argument("--box", nargs=4, type=float, required=True, metavar=("X0", "Y0", "X1", "Y1"), help="the drawn window, die coordinates, um")
    ap.add_argument("--extent", nargs=4, type=float, default=None, metavar=("X0", "Y0", "X1", "Y1"), help="where the whole image goes (default: the box); a larger extent is clipped to the box, e.g. a disc wider than the channel between two PDN pairs")
    ap.add_argument("--pixel", type=float, default=0.6, help="pixel size, um")
    ap.add_argument("--exclude", nargs=4, type=float, action="append", default=[], metavar=("X0", "Y0", "X1", "Y1"), help="Metal4 to stay clear of (die um); repeatable")
    ap.add_argument("--clearance", type=float, default=1.0, help="grown around every exclusion, um")
    ap.add_argument("--mode", choices=("plate", "ink"), default="plate")
    ap.add_argument("--threshold", type=float, default=128)
    ap.add_argument("--no-disc", action="store_true", help="do not clip to the avatar's disc")
    ap.add_argument("--nofill", choices=("metal4", "all"), default="metal4", help="fill-exclusion markers over the box: Metal4 only, or every layer (for a box whose rows are cut out so nothing lies under the art)")
    ap.add_argument("--cell", default="tt_um_pettit_calvin")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    x0, y0, x1, y1 = a.box
    ex0, ey0, ex1, ey1 = a.extent or a.box
    # the whole image on the extent's grid, then the box's window of it; the
    # box is snapped to that grid so the pixels line up
    we_px, he_px = int(round((ex1 - ex0) / a.pixel)), int(round((ey1 - ey0) / a.pixel))
    if a.image.lower().endswith((".gds", ".gds2", ".oas")):
        full, disc = load_mask_gds(a.image, we_px, he_px, a.pixel)       # already in die orientation
    else:
        full, disc = load_mask(a.image, we_px, he_px, a.mode, a.threshold, not a.no_disc)
        full = full[::-1, :]                  # the image's row 0 is the top: die orientation has row 0 at the bottom
    cx0, cy0 = int(round((x0 - ex0) / a.pixel)), int(round((y0 - ey0) / a.pixel))
    cx1, cy1 = int(round((x1 - ex0) / a.pixel)), int(round((y1 - ey0) / a.pixel))
    cx0, cy0, cx1, cy1 = max(cx0, 0), max(cy0, 0), min(cx1, we_px), min(cy1, he_px)
    x0, y0 = ex0 + cx0 * a.pixel, ey0 + cy0 * a.pixel
    mask = full[cy0:cy1, cx0:cx1]
    h_px, w_px = mask.shape
    disc = (disc[0] - cx0, disc[1] - cy0, disc[2])
    # exclusions: every pixel touching an exclusion grown by the clearance
    for kx0, ky0, kx1, ky1 in a.exclude:
        gx0 = int(math.floor((kx0 - a.clearance - x0) / a.pixel)); gx1 = int(math.ceil((kx1 + a.clearance - x0) / a.pixel))
        gy0 = int(math.floor((ky0 - a.clearance - y0) / a.pixel)); gy1 = int(math.ceil((ky1 + a.clearance - y0) / a.pixel))
        mask[max(gy0, 0):max(gy1, 0), max(gx0, 0):max(gx1, 0)] = False
    mask = clean(mask)

    os.makedirs(a.out, exist_ok=True)
    ly = kdb.Layout(); ly.dbu = 0.001
    cell = ly.create_cell(a.cell)
    l_m4 = ly.layer(*LAYER_METAL4); l_nf = ly.layer(*LAYER_NOFILL)
    # The metal goes into the GDS as one rectangle per horizontal run of
    # pixels, never as merged polygons: a merged plate has holes (the eyes
    # inside the face), which GDS can only write as a boundary with cut lines
    # that visits the same vertices twice, and the Tiny Tapeout 3D viewer's
    # triangulator (CDT) throws on such a polygon.  Rectangles have no holes
    # and no repeated vertices; the DRC merges touching shapes before it
    # checks, so the geometry it sees is the same.
    px = int(round(a.pixel * 1000))
    rects = 0
    for y in range(h_px):
        x = 0
        while x < w_px:
            if mask[y, x]:
                x1 = x
                while x1 < w_px and mask[y, x1]:
                    x1 += 1
                cell.shapes(l_m4).insert(kdb.Box(x * px, y * px, x1 * px, (y + 1) * px))
                rects += 1
                x = x1
            else:
                x += 1
    reg = kdb.Region(cell.begin_shapes_rec(l_m4))
    reg.merge()                                # the merged view, for the checks and the report only
    for lname, ld in (NOFILL_ALL.items() if a.nofill == "all" else [("Metal4", LAYER_NOFILL)]):
        cell.shapes(ly.layer(*ld)).insert(kdb.Box(0, 0, w_px * px, h_px * px))
    gds = os.path.join(a.out, a.cell + ".gds")
    ly.write(gds)

    # the rules the grid is supposed to guarantee, checked on the merged shapes
    npoly = reg.count()
    area = reg.area() * 1e-6
    bbox = reg.bbox()
    checks = {"M4.a width 0.20": reg.width_check(200, False, kdb.Region.Euclidian).count(),
              "M4.b space/notch 0.21": reg.space_check(210, False, kdb.Region.Euclidian).count(),
              "M4.d area 0.144": reg.with_area(0, 144000, False).count()}
    wide = reg.sized(-195).sized(195)
    checks["M4.e wide 0.24"] = reg.separation_check(wide, 240, False, kdb.Region.Euclidian).count()
    for k, v in checks.items():
        print(f"  self-check {k}: {v} violations")
    if any(checks.values()):
        raise SystemExit("the art violates a Metal4 rule it was meant to meet by construction")
    lef = os.path.join(a.out, a.cell + ".lef")
    with open(lef, "w") as f:
        f.write("VERSION 5.8 ;\nBUSBITCHARS \"[]\" ;\nDIVIDERCHAR \"/\" ;\n\n")
        f.write(f"MACRO {a.cell}\n  CLASS BLOCK ;\n  ORIGIN 0 0 ;\n  FOREIGN {a.cell} 0 0 ;\n")
        f.write(f"  SIZE {w_px * a.pixel:.3f} BY {h_px * a.pixel:.3f} ;\n  SYMMETRY X Y ;\n")
        f.write(f"  OBS\n      LAYER Metal4 ;\n        RECT 0 0 {w_px * a.pixel:.3f} {h_px * a.pixel:.3f} ;\n  END\nEND {a.cell}\n\nEND LIBRARY\n")
    info = {
        "gds": os.path.abspath(gds), "cell": a.cell, "lef": os.path.abspath(lef),
        "origin": [round(x0, 3), round(y0, 3)], "box": [round(x0, 3), round(y0, 3), round(x0 + w_px * a.pixel, 3), round(y0 + h_px * a.pixel, 3)],
        "pixel": a.pixel, "pixels": [w_px, h_px], "metal_pixels": int(mask.sum()),
        "rectangles": rects, "merged_polygons": npoly, "metal_area_um2": round(area, 2),
        "routing_obstruction": ["Metal4", x0, y0, round(x0 + w_px * a.pixel, 3), round(y0 + h_px * a.pixel, 3)],
        "exclusions": a.exclude, "clearance": a.clearance, "mode": a.mode, "extent": [ex0, ey0, ex1, ey1], "nofill": a.nofill,
    }
    with open(os.path.join(a.out, "art.json"), "w") as f:
        json.dump(info, f, indent=2)

    # preview: metal white, empty black, exclusions dark red, 6 px per pixel
    S = 6
    img = np.zeros((h_px * S, w_px * S, 3), np.uint8)
    img[np.kron(mask, np.ones((S, S), bool))] = (235, 235, 235)
    for kx0, ky0, kx1, ky1 in a.exclude:
        gx0 = int(round((kx0 - x0) / a.pixel * S)); gx1 = int(round((kx1 - x0) / a.pixel * S))
        gy0 = int(round((ky0 - y0) / a.pixel * S)); gy1 = int(round((ky1 - y0) / a.pixel * S))
        img[max(gy0, 0):max(gy1, 0), max(gx0, 0):max(gx1, 0)] = (120, 30, 30)
    Image.fromarray(img[::-1, :, :]).save(os.path.join(a.out, "preview.png"))
    print(f"{a.cell}: {w_px} x {h_px} pixels of {a.pixel} um = {w_px * a.pixel:.1f} x {h_px * a.pixel:.1f} um at ({x0}, {y0}); "
          f"{int(mask.sum())} metal pixels as {rects} rectangles ({npoly} merged polygons), {area:.0f} um2 of Metal4; disc centre/radius (px) {tuple(round(float(v), 1) for v in disc)}")
    print(f"wrote {gds}, {lef}, art.json, preview.png")


if __name__ == "__main__":
    main()
