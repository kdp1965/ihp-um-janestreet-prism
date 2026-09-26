# Extend the tile's vertical power stripes across every hard macro, and
# power the IHP SRAM macro from stripes on its own tracks (both bit-cell
# arrays and the standard-cell band between them each get complete
# VPWR/VGND pairs; see allocate_sram).
#
# The Tiny Tapeout CMOS5L tile has a single-layer PDN (Metal4 stripes, no
# horizontal straps), so a macro's Metal4 power pins can only be reached by a
# tile stripe running straight over them. pdngen trims its stripes around
# macros; this step draws each macro's VPWR/VGND pin columns from the bottom
# to the top of the core as tile stripes (and tile power pins), which bridges
# the gap and lands exactly on the macro pins. It warns if a macro pin column
# is not aligned with an existing tile stripe.
#
# Column choice (allocate_sram): the grid's stripes moved onto the SRAM's own
# columns plus complete pairs per region; --sram-all-columns adds every other
# legal column, --sram-array-every-other every second pair position of the
# bit-cell arrays only.  No SRAM column stripe lands on a hard macro's signal
# pin on the stripe layer, since the stripes run the full core height.
#
# It finishes by leaving exactly one full-height box per stripe x: the
# abstract LEF turns every Metal4 power box into a PORT rect, and the Tiny
# Tapeout pin check rejects a power port rect that stops short of either
# edge (pdngen's segments between the macros of a column, and its channel
# repair stripe beside a macro; see tidy()).
import collections

import click
import odb
from reader import click_odb


SRAM_PINS = {"VPWR": ("VDD!", "VDDARRAY!"), "VGND": ("VSS!",)}   # IHP SRAM macro power pins


def is_sram(master):
    return master.findMTerm("VDD!") is not None and master.findMTerm("VSS!") is not None


@click.command()
@click.option("--layer", default="Metal4", help="Vertical PDN layer of the tile")
@click.option("--sram-layer", default=None, help="Layer of the IHP SRAM's power columns when it is not the tile's stripe layer "
              "(e.g. Metal4 columns under TopMetal1 stripes): the stripes drawn on the columns then get via stacks down to them")
@click.option("--clearance", "clearance_um", default=0.24, type=float, help="Spacing (um) kept between a drawn stripe and the other net's macro rails / tile pins on the stripe layer")
@click.option("--stack-pitch", default=10.0, type=float, help="Spacing (um) of the via stacks along an SRAM power column")
@click.option("--pin-face-margin", default=3.0, type=float, help="No rail via stack within this distance (um) of a macro edge that carries pins: "
              "the stack's landing patches would sit on the pins' escape route (an unfixable short)")
@click.option("--sram-all-columns/--sram-grid-columns", default=False,
              help="Put a stripe on every legal supply column of an IHP SRAM, not only the ones the "
                   "tile grid and the per-region minimum ask for.  The macro's internal mesh then "
                   "carries far less current; it costs one full-height stripe per column in that corridor")
@click.option("--sram-array-every-other/--no-sram-array-every-other", default=False,
              help="In each bit-cell array of an IHP SRAM, a VPWR/VGND stripe pair on every other available "
                   "pair position (VGND one column right of VPWR, as the tile grid pairs them), phased so the "
                   "grid's own pairs stay: about half the array stripes of --sram-all-columns.  The macro's "
                   "standard-cell band keeps only what the grid and the two-pair minimum give it")
@click_odb
def extend(reader, layer, sram_layer, clearance_um, stack_pitch, pin_face_margin, sram_all_columns, sram_array_every_other):
    if sram_all_columns and sram_array_every_other:
        raise click.ClickException("--sram-all-columns already covers every column; drop --sram-array-every-other")
    block = reader.block
    tech = reader.tech
    m = tech.findLayer(layer)
    core = block.getCoreArea()
    ylo, yhi = core.yMin(), core.yMax()
    dbu = block.getDefUnits()
    sram_layer = sram_layer or layer
    same_layer = sram_layer == layer

    # pdngen's via masters by layer pair (bottom -> top)
    routing = sorted((l for l in tech.getLayers() if l.getType() == "ROUTING"), key=lambda l: l.getRoutingLevel())
    names = [l.getName() for l in routing]
    by_pair = {}
    for v in block.getVias():
        if v.getBottomLayer() is not None and v.getTopLayer() is not None:
            by_pair.setdefault((v.getBottomLayer().getName(), v.getTopLayer().getName()), []).append(v)

    def stack(lo, hi, pick):
        """one via master per layer pair from lo up to hi"""
        out = []
        for a, b in zip(names[names.index(lo):names.index(hi)], names[names.index(lo) + 1:names.index(hi) + 1]):
            cands = by_pair.get((a, b), [])
            if not cands:
                print(f"[WARNING] no via master between {a} and {b} in the design: stacks through it are skipped")
                return []
            out.append(pick(cands))
        return out

    def height(v):
        bb = v.getBBox()
        return bb.yMax() - bb.yMin()

    # The stacks that join a Metal1 rail to a stripe (rail-sized, one cut row)
    rail_vias = stack("Metal1", layer, lambda c: min(c, key=height))
    # The stacks from a stripe down to an SRAM power column on a lower layer
    sram_vias = [] if same_layer else stack(sram_layer, layer, lambda c: max(c, key=height))
    print(f"[INFO] rail via stack: {' + '.join(v.getName() for v in rail_vias) or 'none'}")
    if not same_layer:
        print(f"[INFO] SRAM column via stack ({sram_layer} -> {layer}): {' + '.join(v.getName() for v in sram_vias) or 'none'}")

    # Signal pins of the tile on the stripe layer: a stripe may not sit under one
    pin_xs = []
    for bterm in block.getBTerms():
        if bterm.getSigType() in ("POWER", "GROUND"):
            continue
        for bpin in bterm.getBPins():
            for box in bpin.getBoxes():
                if box.getTechLayer() is not None and box.getTechLayer().getName() == layer:
                    pin_xs.append((box.xMin(), box.xMax()))

    # Signal pins of the hard macros on the stripe layer (tile x ranges).  An
    # SRAM column stripe runs the full core height, so it may not land on one
    # anywhere: in runs/dma_band (all-columns) the stripes crossing
    # CFGMEMS_LEFT[1].cfgmem_lo (top-left, over the SRAMs' x range) sat on or
    # beside 41 of its 56 Metal4 data pins, 12 fixed Metal4 shorts / spacing
    # errors in the final DRC.  R0 / MX placements keep the pins' x.
    macro_pin_xs = []
    for inst in block.getInsts():
        master = inst.getMaster()
        if not master.isBlock():
            continue
        mox = inst.getBBox().xMin()
        for mterm in master.getMTerms():
            if mterm.getSigType() in ("POWER", "GROUND"):
                continue
            for mpin in mterm.getMPins():
                for box in mpin.getGeometry():
                    if box.getTechLayer() is not None and box.getTechLayer().getName() == layer:
                        macro_pin_xs.append((mox + box.xMin(), mox + box.xMax()))
    print(f"[INFO] {len(macro_pin_xs)} macro signal pin shapes on {layer}: SRAM column stripes keep clear of them")

    # Hard macros up front: SRAM footprints with their power columns (per
    # net), and the Metal4 rails of every other macro (per net), so a stripe
    # drawn for one macro can be checked against all the others it crosses.
    sram_cols = {"VPWR": [], "VGND": []}     # (x0, x1) of a column, tile coordinates
    sram_boxes = []
    sram_rects = []
    macro_rails = {"VPWR": [], "VGND": []}   # (x0, x1) of a CFGMEM-style rail
    for inst in block.getInsts():
        master = inst.getMaster()
        if not master.isBlock():
            continue
        ib = inst.getBBox()
        ox = ib.xMin()
        if is_sram(master):
            sram_boxes.append((ib.xMin(), ib.xMax()))
            sram_rects.append(odb.Rect(ib.xMin(), ib.yMin(), ib.xMax(), ib.yMax()))
            for nn, pins in SRAM_PINS.items():
                for pin_name in pins:
                    mterm = master.findMTerm(pin_name)
                    if mterm is None:
                        continue
                    for mpin in mterm.getMPins():
                        for box in mpin.getGeometry():
                            if box.getTechLayer().getName() == sram_layer:
                                sram_cols[nn].append((ox + box.xMin(), ox + box.xMax()))
            continue
        for nn in ("VPWR", "VGND"):
            mterm = master.findMTerm(nn)
            if mterm is None:
                continue
            for mpin in mterm.getMPins():
                for box in mpin.getGeometry():
                    if box.getTechLayer().getName() == layer:
                        macro_rails[nn].append((ox + box.xMin(), ox + box.xMax()))
    for nn in sram_cols:
        sram_cols[nn] = sorted(set(sram_cols[nn]))
    clearance = int(clearance_um * dbu)      # spacing on the stripe layer (0.24 um for a 2.1 um Metal4 wire, 1.64 on TopMetal1)

    # Macro edges that carry signal pins (x range, y of the edge): no rail via
    # stack may land within pin_face_margin of them.  A stack's Metal1-Metal3
    # patches are 1.9 um wide and sit on the row rail 1-2 um beyond the edge,
    # exactly where the pins' escape wires must go; the router then has no
    # legal connection for those pins (the stuck single short of run g2_8x4).
    pin_faces = []
    edge_tol = int(3.0 * dbu)
    for inst in block.getInsts():
        if not inst.getMaster().isBlock():
            continue
        ib = inst.getBBox()
        top = bottom = 0
        for it in inst.getITerms():
            if it.getMTerm().getSigType() != "SIGNAL":
                continue
            bb = it.getBBox()
            if ib.yMax() - bb.yMax() <= edge_tol:
                top += 1
            if bb.yMin() - ib.yMin() <= edge_tol:
                bottom += 1
        if top:
            pin_faces.append((ib.xMin(), ib.xMax(), ib.yMax()))
        if bottom:
            pin_faces.append((ib.xMin(), ib.xMax(), ib.yMin()))
    face_margin = int(pin_face_margin * dbu)

    def near_pin_face(x, y):
        return any(fx0 - face_margin <= x <= fx1 + face_margin and abs(y - fy) <= face_margin for fx0, fx1, fy in pin_faces)

    def inside_sram(b):
        return any(r.xMin() <= b.xMin() and b.xMax() <= r.xMax() and r.yMin() <= b.yMin() and b.yMax() <= r.yMax()
                   for r in sram_rects)

    def on_sram_column(x0, x1, nn):
        """A full-height stripe [x0, x1] may cross an SRAM only inside one of
        its own columns of the same polarity (its Metal4 is obstructed
        everywhere else, with 0.26 um to spare).  A stripe layer above the
        macro's top obstruction (TopMetal1 over the IHP SRAM) is free."""
        if not same_layer:
            return True
        for (sx0, sx1) in sram_boxes:
            if x1 <= sx0 or x0 >= sx1:
                continue
            if not any(c0 - 0.02 * dbu <= x0 and x1 <= c1 + 0.02 * dbu for (c0, c1) in sram_cols[nn]):
                return False
        return True

    def clear_of_rails(x0, x1, nn):
        other = "VGND" if nn == "VPWR" else "VPWR"
        return all(x1 + clearance <= r0 or x0 - clearance >= r1 for (r0, r1) in macro_rails[other])

    def clear_of_pins(x0, x1):
        return all(x1 + clearance <= px0 or x0 - clearance >= px1 for (px0, px1) in pin_xs)

    full_tol = int(1.0 * dbu)

    def is_full(b):
        return b.yMin() <= ylo + full_tol and b.yMax() >= yhi - full_tol

    def xkey(b):
        return int(((b.xMin() + b.xMax()) // 2) // (0.01 * dbu))   # stripe centre, 0.01 um bins

    def tidy(net_name, swire, bpin, rails):
        """Leave exactly one full-height stripe box (and one pin box) per
        stripe x.  The abstract LEF exports every Metal4 power box as a PORT
        rect and the Tiny Tapeout pin check rejects any power port rect that
        does not reach within 10 um of both the bottom and the top edge, so:
          - where a full-height stripe exists, drop the partial-height
            segments pdngen left in the gaps between the macros of a column,
            and the duplicate full-height copies drawn once per macro;
          - where only partial-height segments exist (pdngen's channel repair
            beside a macro whose halo pushes the rows past the grid stripe),
            replace them by one full-height stripe and give it rail vias on
            every row it newly crosses.
        Vias are never removed: a via on a dropped segment still lands on the
        full-height stripe at the same x."""
        boxes = [
            b for b in swire.getWires()
            if b.getTechLayer() is not None and b.getTechLayer().getName() == layer
            and (b.yMax() - b.yMin()) > (b.xMax() - b.xMin())
        ]
        vias = [b for b in swire.getWires() if b.getTechLayer() is None]
        pboxes = []
        if bpin is not None:
            pboxes = [
                p for p in bpin.getBoxes()
                if p.getTechLayer() is not None and p.getTechLayer().getName() == layer
                and (p.yMax() - p.yMin()) > (p.xMax() - p.xMin())
            ]
        groups, pgroups = {}, {}
        for b in boxes:
            groups.setdefault(xkey(b), []).append(b)
        for p in pboxes:
            pgroups.setdefault(xkey(p), []).append(p)
        dropped = extended = pins_dropped = orphans = 0
        for k, sb in sorted(groups.items()):
            x0 = min(b.xMin() for b in sb)
            x1 = max(b.xMax() for b in sb)
            cx = (x0 + x1) // 2
            full = [b for b in sb if is_full(b)]
            if full:
                keep = max(full, key=lambda b: b.yMax() - b.yMin())
                for b in sb:
                    if b is not keep:
                        odb.dbSBox_destroy(b)
                        dropped += 1
            else:
                if not (on_sram_column(x0, x1, net_name) and clear_of_rails(x0, x1, net_name) and clear_of_pins(x0, x1)):
                    print(f"[WARNING] {net_name}: partial-height stripe at x={cx/dbu:.2f} um is blocked from running "
                          f"full height; the Tiny Tapeout pin check will reject its pin boxes")
                    continue
                for b in sb:
                    odb.dbSBox_destroy(b)
                keep = odb.dbSBox_create(swire, m, x0, ylo, x1, yhi, "STRIPE")
                have = [(v.yMin() + v.yMax()) // 2 for v in vias if abs((v.xMin() + v.xMax()) // 2 - cx) < 0.5 * dbu]
                new_vias = 0
                for r in rails:
                    if r.xMin() <= cx <= r.xMax():
                        ry = (r.yMin() + r.yMax()) // 2
                        if near_pin_face(cx, ry):
                            continue
                        if not any(abs(h - ry) < 0.3 * dbu for h in have):
                            for via in rail_vias:
                                odb.dbSBox_create(swire, via, cx, ry, "STRIPE")
                            new_vias += 1
                extended += 1
                print(f"[INFO] {net_name}: {len(sb)} partial-height segments at x={cx/dbu:.2f} um replaced by one "
                      f"full-height stripe (+{new_vias} rail via stacks)")
            if bpin is not None:
                for p in pgroups.pop(k, []):
                    odb.dbBox_destroy(p)
                    pins_dropped += 1
                odb.dbBox_create(bpin, m, keep.xMin(), keep.yMin(), keep.xMax(), keep.yMax())
                pins_dropped -= 1
        for k, ps in pgroups.items():           # pin boxes with no stripe under them
            for p in ps:
                odb.dbBox_destroy(p)
                orphans += 1
        print(f"[INFO] {net_name}: tidy: {dropped} redundant stripe segments dropped, {extended} partial-height "
              f"stripes extended to full height, {pins_dropped} duplicate and {orphans} orphan pin boxes dropped, "
              f"{len(groups)} stripes remain")

    # ---- IHP SRAM: which of the macro's Metal4 power columns carry a tile stripe.
    # Decided for both nets at once, from the pdngen grid, before anything moves.
    pair_gap = int(6.5 * dbu)       # a VPWR/VGND pair sits on adjacent columns, 5.62 um apart
    band_margin = int(8.0 * dbu)    # a VSS column this close to the band's VDD columns belongs to the band
    pin_margin = int(0.5 * dbu)

    def allocate_sram(inst, grid):
        """Columns of an IHP SRAM instance that get a full-height tile stripe,
        per net, in tile coordinates.

        The macro has three regions with separate internal meshes: two
        bit-cell arrays (VDDARRAY!/VSS! columns, with the periphery's VDD!
        columns below them on the same x) and, between them, a band of the
        macro's own standard cells (full-height VDD! columns and the VSS!
        columns next to them).  Every tile stripe crossing the footprint moves
        onto the nearest free column of its polarity, as pdngen would want;
        then each region is made whole: a stripe whose partner of the other
        polarity landed in a different region gets a partner on the adjacent
        column of its own region, and the band gets at least two VPWR/VGND
        pairs.  (Uri: any number of full-height power pins is fine.)"""
        master = inst.getMaster()
        ib = inst.getBBox()
        ox = ib.xMin()
        h = master.getHeight()
        vdd_full, vdd_rest, vss = set(), set(), set()
        for pin_name in ("VDD!", "VDDARRAY!", "VSS!"):
            mterm = master.findMTerm(pin_name)
            if mterm is None:
                continue
            for mpin in mterm.getMPins():
                for box in mpin.getGeometry():
                    if box.getTechLayer().getName() != sram_layer:
                        continue
                    c = (ox + box.xMin(), ox + box.xMax())
                    if pin_name == "VSS!":
                        vss.add(c)
                    elif pin_name == "VDD!" and box.yMax() - box.yMin() >= 0.9 * h:
                        vdd_full.add(c)
                    else:
                        vdd_rest.add(c)

        def centre(c):
            return (c[0] + c[1]) // 2

        band_lo = band_hi = None
        if vdd_full:
            band_lo = min(centre(c) for c in vdd_full) - band_margin
            band_hi = max(centre(c) for c in vdd_full) + band_margin

        def region_of(c):
            x = centre(c)
            if band_lo is None or x < band_lo:
                return "array L"
            return "band" if x <= band_hi else "array R"

        cols = {"VPWR": {c: region_of(c) for c in vdd_full | vdd_rest},
                "VGND": {c: region_of(c) for c in vss}}
        regions = [r for r in ("array L", "band", "array R")
                   if r in set(cols["VPWR"].values()) | set(cols["VGND"].values())]
        chosen = {"VPWR": [], "VGND": []}
        other_of = {"VPWR": "VGND", "VGND": "VPWR"}

        def clear(c, nn):
            return all(c[1] + pin_margin < px0 or c[0] - pin_margin > px1 for (px0, px1) in pin_xs) \
                and all(c[1] + pin_margin < px0 or c[0] - pin_margin > px1 for (px0, px1) in macro_pin_xs) \
                and clear_of_rails(c[0], c[1], nn)

        def free(nn, region=None):
            return [c for c, r in cols[nn].items()
                    if c not in chosen[nn] and (region is None or r == region) and clear(c, nn)]

        def partnered(c, nn):
            return any(abs(centre(o) - centre(c)) <= pair_gap for o in chosen[other_of[nn]])

        def pairs(r):
            return sum(1 for c in chosen["VPWR"] if cols["VPWR"][c] == r and partnered(c, "VPWR"))

        def where(c):
            return f"x={centre(c)/dbu:.2f} um ({cols['VPWR'].get(c) or cols['VGND'].get(c)})"

        # 1. every tile stripe crossing the footprint moves onto the nearest free column
        n_grid = {}
        for nn in ("VPWR", "VGND"):
            targets = sorted(set(centre((b.xMin(), b.xMax())) for b in grid[nn]
                                 if b.xMax() > ib.xMin() and b.xMin() < ib.xMax()))
            n_grid[nn] = len(targets)
            for tx in targets:
                cands = free(nn)
                if not cands:
                    print(f"[WARNING] {inst.getName()}: no free {nn} column for the stripe at x={tx/dbu:.2f}")
                    continue
                c = min(cands, key=lambda c: abs(centre(c) - tx))
                chosen[nn].append(c)
                shift = (centre(c) - tx) / dbu
                if abs(shift) > 0.05:
                    print(f"[INFO] {inst.getName()}: {nn} stripe at x={tx/dbu:.2f} moved {shift:+.2f} um onto a column")

        # 2. a stripe without a partner on an adjacent column gets one in its own region
        def complete_pairs():
            for nn in ("VPWR", "VGND"):
                other = other_of[nn]
                for c in list(chosen[nn]):
                    if partnered(c, nn):
                        continue
                    r = cols[nn][c]
                    cands = free(other, r)
                    if not cands:
                        print(f"[WARNING] {inst.getName()}: no free {other} column in the {r} to pair with the "
                              f"{nn} stripe at {where(c)}")
                        continue
                    same = [centre(e) for e in chosen[other] if cols[other][e] == r]
                    o = min(cands, key=lambda o: (abs(centre(o) - centre(c)),
                                                  -min((abs(centre(o) - x) for x in same), default=0)))
                    chosen[other].append(o)
                    print(f"[INFO] {inst.getName()}: {other} stripe added at {where(o)} to pair with the {nn} stripe at {where(c)}")

        complete_pairs()

        # 3. the band gets at least two pairs, spread apart
        if "band" in regions:
            while pairs("band") < 2:
                cands = free("VPWR", "band")
                if not cands:
                    print(f"[WARNING] {inst.getName()}: the band has only {pairs('band')} VPWR/VGND pair(s) and no free VPWR column")
                    break
                have = [centre(c) for c in chosen["VPWR"] if cols["VPWR"][c] == "band"]
                c = max(cands, key=lambda c: (min((abs(centre(c) - x) for x in have), default=0), -centre(c)))
                chosen["VPWR"].append(c)
                print(f"[INFO] {inst.getName()}: VPWR stripe added at {where(c)} so the band has two pairs")
                complete_pairs()

        # 4. every remaining legal column, when the corridor can afford it:
        #    the columns are all one net inside the macro, so feeding more of
        #    them shortens the path from the grid to the far side of an array
        if sram_all_columns:
            added = {"VPWR": 0, "VGND": 0}
            for nn in ("VPWR", "VGND"):
                for c in sorted(free(nn), key=centre):
                    chosen[nn].append(c)
                    added[nn] += 1
            print(f"[INFO] {inst.getName()}: all-columns: +{added['VPWR']} VPWR / +{added['VGND']} VGND "
                  f"stripes on the remaining legal columns")

        # 4b. every other VPWR/VGND pair position of each bit-cell array.  A
        #     pair position is a VPWR column with a VGND column one column
        #     pitch (5.62 um) to its right, as the tile grid pairs its stripes;
        #     the alternation is phased to the pairs the grid already put in
        #     the array, so those stay and the new ones fall between them.  A
        #     position with either column taken counts as served.  The band
        #     (the macro's own standard cells) keeps what steps 1-3 gave it.
        if sram_array_every_other:
            col_pitch = int(5.62 * dbu)
            tol = int(1.0 * dbu)
            for r in ("array L", "array R"):
                vps = sorted((c for c, rr in cols["VPWR"].items() if rr == r), key=centre)
                vgs = sorted((c for c, rr in cols["VGND"].items() if rr == r), key=centre)
                locs = []
                for c in vps:
                    right = [g for g in vgs if abs(centre(g) - centre(c) - col_pitch) <= tol]
                    if right:
                        locs.append((c, right[0]))
                if not locs:
                    continue
                held = [i for i, (c, g) in enumerate(locs) if c in chosen["VPWR"] or g in chosen["VGND"]]
                phase = collections.Counter(i % 2 for i in held).most_common(1)[0][0] if held else 0
                n = blocked = 0
                for i, (c, g) in enumerate(locs):
                    if i % 2 != phase or c in chosen["VPWR"] or g in chosen["VGND"]:
                        continue
                    if not (clear(c, "VPWR") and clear(g, "VGND")):
                        blocked += 1
                        continue
                    chosen["VPWR"].append(c)
                    chosen["VGND"].append(g)
                    n += 1
                print(f"[INFO] {inst.getName()}: array-every-other: {r}: {len(locs)} pair positions, "
                      f"{len(held)} held by the grid, +{n} pairs ({blocked} positions blocked by pins / rails)")

        print(f"[INFO] {inst.getName()}: " + ", ".join(f"{r}: {pairs(r)} pairs" for r in regions) +
              f"; VPWR {len(chosen['VPWR'])} / VGND {len(chosen['VGND'])} stripes for the "
              f"{n_grid['VPWR']} / {n_grid['VGND']} tile stripes crossing the macro")
        return {nn: sorted(chosen[nn]) for nn in chosen}

    grid = {}
    for net_name in ("VPWR", "VGND"):
        net = block.findNet(net_name)
        if net is None:
            raise click.ClickException(f"net {net_name} not found")
        grid[net_name] = [
            b for sw in net.getSWires() for b in sw.getWires()
            if b.getTechLayer() is not None and b.getTechLayer().getName() == layer
            and (b.yMax() - b.yMin()) > (b.xMax() - b.xMin())
        ]
    sram_alloc = {}
    for inst in block.getInsts():
        if inst.getMaster().isBlock() and is_sram(inst.getMaster()):
            sram_alloc[inst.getName()] = allocate_sram(inst, grid)

    for net_name in ("VPWR", "VGND"):
        net = block.findNet(net_name)
        if net is None:
            raise click.ClickException(f"net {net_name} not found")
        swires = net.getSWires()
        swire = swires[0] if swires else odb.dbSWire_create(net, "ROUTED")
        stripes = [
            b for b in swire.getWires()
            if b.getTechLayer() is not None  # via boxes carry no layer
            and b.getTechLayer().getName() == layer
            and (b.yMax() - b.yMin()) > (b.xMax() - b.xMin())
        ]
        rails = [
            b for b in swire.getWires()
            if b.getTechLayer() is not None
            and b.getTechLayer().getName() == "Metal1"
            and (b.xMax() - b.xMin()) > (b.yMax() - b.yMin())
        ]
        bpin = None
        for bterm in net.getBTerms():
            pins = bterm.getBPins()
            if pins:
                bpin = pins[0]
                break
        added = 0
        for inst in block.getInsts():
            master = inst.getMaster()
            if not master.isBlock():
                continue
            if inst.getOrient() not in ("R0", "MX"):
                raise click.ClickException(
                    f"{inst.getName()} is placed with orientation {inst.getOrient()}; "
                    "only R0 (N) and MX (FS) are supported by this step"
                )
            ib = inst.getBBox()
            ox, oy = ib.xMin(), ib.yMin()  # macro origin in tile coordinates

            if is_sram(master):
                # ---- IHP SRAM: its Metal4 power columns cannot coincide with the
                # tile grid, so the tile stripes crossing its footprint go away and
                # full-height stripes are drawn on the macro's own tracks instead
                # (columns chosen by allocate_sram).  The rows above / below the
                # macro get their rail vias back on the new stripes.
                x0, x1 = ib.xMin(), ib.xMax()
                columns = sram_alloc[inst.getName()][net_name]
                if not columns:
                    print(f"[WARNING] {inst.getName()}: no {net_name} columns on {layer}")
                    continue
                # any stripe that overlaps the footprint, including one straddling
                # the macro edge (pdngen leaves a partial-height stub of those)
                crossing = [b for b in stripes if b.xMax() > x0 and b.xMin() < x1]
                # remove the crossing tile stripes, their pin boxes and their rail
                # vias - only what sits on those stripes, so a second SRAM on the
                # same columns (which finds nothing to replace) keeps the vias
                # the first pass added for the rows above it
                removed_x = [(b.xMin(), b.xMax()) for b in crossing]
                def on_removed(box):
                    return any(box.xMax() > rx0 and box.xMin() < rx1 for (rx0, rx1) in removed_x)
                removed = 0
                for b in crossing:
                    odb.dbSBox_destroy(b)
                    removed += 1
                if bpin is not None:
                    for box in list(bpin.getBoxes()):
                        if box.getTechLayer() is not None and box.getTechLayer().getName() == layer \
                           and on_removed(box):
                            odb.dbBox_destroy(box)
                for b in list(swire.getWires()):
                    if inside_sram(b) or not on_removed(b):
                        continue
                    lyr = b.getTechLayer()
                    if lyr is None:
                        odb.dbSBox_destroy(b)      # a via on a removed stripe (column stacks inside an SRAM stay)
                    elif lyr.getName() not in (layer, "Metal1") and (b.xMax() - b.xMin()) < (b.yMax() - b.yMin()) * 8:
                        odb.dbSBox_destroy(b)      # pdngen's small patch on an intermediate layer of that via stack
                stripes = [b for b in stripes if b not in crossing]
                for c in columns:
                    stripes.append(odb.dbSBox_create(swire, m, c[0], ylo, c[1], yhi, "STRIPE"))
                    if bpin is not None:
                        odb.dbBox_create(bpin, m, c[0], ylo, c[1], yhi)
                    added += 1
                    # rail vias where the new stripe crosses a Metal1 rail outside the macro
                    cx = (c[0] + c[1]) // 2
                    for r in rails:
                        if r.xMin() <= cx <= r.xMax() and (r.yMax() <= ib.yMin() or r.yMin() >= ib.yMax()):
                            ry = (r.yMin() + r.yMax()) // 2
                            if near_pin_face(cx, ry):
                                continue
                            for via in rail_vias:
                                odb.dbSBox_create(swire, via, cx, ry, "STRIPE")
                print(f"[INFO] {inst.getName()}: {net_name}: {removed} tile stripes replaced by {len(columns)} on the macro's tracks "
                      f"({len(rail_vias)} via masters per rail crossing)")
                continue

            # ---- CFGMEM-style macro: stripes on the tile grid pass straight through
            mterm = master.findMTerm(net_name)
            if mterm is None:
                print(f"[WARNING] macro {inst.getName()} has no pin {net_name}")
                continue
            # R0 (N) or MX (FS, flipped about the x axis): both keep the pin
            # x positions, and the stripes drawn here span the full core height
            # so the pins' y positions do not matter.
            for mpin in mterm.getMPins():
                for box in mpin.getGeometry():
                    if box.getTechLayer().getName() != layer:
                        continue
                    r = odb.Rect(ox + box.xMin(), oy + box.yMin(), ox + box.xMax(), oy + box.yMax())
                    cx = (r.xMin() + r.xMax()) / 2
                    if not on_sram_column(r.xMin(), r.xMax(), net_name):
                        print(f"[WARNING] {inst.getName()} {net_name} rail at x={cx/dbu:.2f} um crosses an SRAM off its "
                              f"columns: no tile stripe on it (fed through the macro's row rails)")
                        continue
                    if not all(r.xMax() + clearance <= px0 or r.xMin() - clearance >= px1 for (px0, px1) in pin_xs):
                        print(f"[WARNING] {inst.getName()} {net_name} rail at x={cx/dbu:.2f} um sits under a tile signal "
                              f"pin: no full-height stripe on it (fed through the macro's row rails)")
                        continue
                    nearest = min(
                        (abs((e.xMin() + e.xMax()) / 2 - cx) for e in stripes), default=None
                    )
                    if nearest is None or nearest > 0.05 * dbu:
                        print(
                            f"[WARNING] {inst.getName()} {net_name} pin column at x={cx/dbu:.3f} um is "
                            f"{'not near any' if nearest is None else f'{nearest/dbu:.3f} um off the nearest'} tile stripe"
                        )
                    odb.dbSBox_create(swire, m, r.xMin(), ylo, r.xMax(), yhi, "STRIPE")
                    if bpin is not None:
                        odb.dbBox_create(bpin, m, r.xMin(), ylo, r.xMax(), yhi)
                    added += 1
        print(f"[INFO] {net_name}: {len(stripes)} tile stripes kept, {added} full-height stripes added over macro pin columns")

        # pdngen's own rail stacks (and any patches) inside a pin-face band go too
        cleared = 0
        for b in list(swire.getWires()):
            if inside_sram(b):
                continue
            lyr = b.getTechLayer()
            is_via = lyr is None
            is_patch = (not is_via) and lyr.getName() not in (layer, "Metal1") and (b.xMax() - b.xMin()) < (b.yMax() - b.yMin()) * 8
            if (is_via or is_patch) and near_pin_face((b.xMin() + b.xMax()) // 2, (b.yMin() + b.yMax()) // 2):
                odb.dbSBox_destroy(b); cleared += 1
        print(f"[INFO] {net_name}: {cleared} via / patch shapes removed from the {pin_face_margin} um bands beside {len(pin_faces)} macro pin faces")

        # ---- SRAM columns on a lower layer: via stacks from the stripe down to
        # every column rect that carries a stripe, spaced along the column
        if sram_vias:
            stacks = 0
            tol = int(0.05 * dbu)
            margin = int(2.0 * dbu)
            step = max(int(stack_pitch * dbu), 1)
            for inst in block.getInsts():
                master = inst.getMaster()
                if not (master.isBlock() and is_sram(master)):
                    continue
                cols = sram_alloc[inst.getName()][net_name]
                ib = inst.getBBox()
                ox, oy, h = ib.xMin(), ib.yMin(), master.getHeight()
                flipped = inst.getOrient() == "MX"       # R0 or MX only (checked above)
                for pin_name in SRAM_PINS[net_name]:
                    mterm = master.findMTerm(pin_name)
                    if mterm is None:
                        continue
                    for mpin in mterm.getMPins():
                        for box in mpin.getGeometry():
                            if box.getTechLayer().getName() != sram_layer:
                                continue
                            rx0, rx1 = ox + box.xMin(), ox + box.xMax()
                            if flipped:
                                ry0, ry1 = oy + h - box.yMax(), oy + h - box.yMin()
                            else:
                                ry0, ry1 = oy + box.yMin(), oy + box.yMax()
                            if not any(abs(c[0] - rx0) <= tol and abs(c[1] - rx1) <= tol for c in cols):
                                continue
                            cx = (rx0 + rx1) // 2
                            ys = list(range(ry0 + margin, ry1 - margin + 1, step)) or [(ry0 + ry1) // 2]
                            for y in ys:
                                for via in sram_vias:
                                    odb.dbSBox_create(swire, via, cx, y, "STRIPE")
                                stacks += 1
            print(f"[INFO] {net_name}: {stacks} via stacks from the {layer} stripes down to the SRAM {sram_layer} columns")
        tidy(net_name, swire, bpin, rails)


if __name__ == "__main__":
    extend()
