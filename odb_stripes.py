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
# It finishes by leaving exactly one full-height box per stripe x: the
# abstract LEF turns every Metal4 power box into a PORT rect, and the Tiny
# Tapeout pin check rejects a power port rect that stops short of either
# edge (pdngen's segments between the macros of a column, and its channel
# repair stripe beside a macro; see tidy()).
import click
import odb
from reader import click_odb


SRAM_PINS = {"VPWR": ("VDD!", "VDDARRAY!"), "VGND": ("VSS!",)}   # IHP SRAM macro power pins


def is_sram(master):
    return master.findMTerm("VDD!") is not None and master.findMTerm("VSS!") is not None


@click.command()
@click.option("--layer", default="Metal4", help="Vertical PDN layer")
@click_odb
def extend(reader, layer):
    block = reader.block
    tech = reader.tech
    m = tech.findLayer(layer)
    core = block.getCoreArea()
    ylo, yhi = core.yMin(), core.yMax()
    dbu = block.getDefUnits()

    # The pdngen via stacks that join a Metal1 rail to a Metal4 stripe (one
    # dbVia per layer pair, 5 cuts across a 2.1 um stripe), by name prefix
    rail_vias = []
    for prefix in ("via1_2_2100_440", "via2_3_2100_440", "via3_4_2100_440"):
        found = [v for v in block.getVias() if v.getName().startswith(prefix)]
        if found:
            rail_vias.append(found[0])

    # Signal pins of the tile (top edge): a stripe may not sit under one
    pin_xs = []
    for bterm in block.getBTerms():
        if bterm.getSigType() in ("POWER", "GROUND"):
            continue
        for bpin in bterm.getBPins():
            for box in bpin.getBoxes():
                pin_xs.append((box.xMin(), box.xMax()))

    # Hard macros up front: SRAM footprints with their power columns (per
    # net), and the Metal4 rails of every other macro (per net), so a stripe
    # drawn for one macro can be checked against all the others it crosses.
    sram_cols = {"VPWR": [], "VGND": []}     # (x0, x1) of a column, tile coordinates
    sram_boxes = []
    macro_rails = {"VPWR": [], "VGND": []}   # (x0, x1) of a CFGMEM-style rail
    for inst in block.getInsts():
        master = inst.getMaster()
        if not master.isBlock():
            continue
        ib = inst.getBBox()
        ox = ib.xMin()
        if is_sram(master):
            sram_boxes.append((ib.xMin(), ib.xMax()))
            for nn, pins in SRAM_PINS.items():
                for pin_name in pins:
                    mterm = master.findMTerm(pin_name)
                    if mterm is None:
                        continue
                    for mpin in mterm.getMPins():
                        for box in mpin.getGeometry():
                            if box.getTechLayer().getName() == layer:
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
    clearance = int(0.24 * dbu)              # Metal4 spacing for a 2.1 um wire

    def on_sram_column(x0, x1, nn):
        """A full-height stripe [x0, x1] may cross an SRAM only inside one of
        its own columns of the same polarity (its Metal4 is obstructed
        everywhere else, with 0.26 um to spare)."""
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
                    if box.getTechLayer().getName() != layer:
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
                    if b.getTechLayer() is None and on_removed(b):
                        odb.dbSBox_destroy(b)      # a via on a removed stripe
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
        tidy(net_name, swire, bpin, rails)


if __name__ == "__main__":
    extend()
