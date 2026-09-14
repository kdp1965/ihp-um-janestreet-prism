# Extend the tile's vertical power stripes across every hard macro, and
# power the IHP SRAM macro from stripes on its own tracks.
#
# The Tiny Tapeout CMOS5L tile has a single-layer PDN (Metal4 stripes, no
# horizontal straps), so a macro's Metal4 power pins can only be reached by a
# tile stripe running straight over them. pdngen trims its stripes around
# macros; this step draws each macro's VPWR/VGND pin columns from the bottom
# to the top of the core as tile stripes (and tile power pins), which bridges
# the gap and lands exactly on the macro pins. It warns if a macro pin column
# is not aligned with an existing tile stripe.
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
                # full-height stripes are drawn on the macro's own tracks instead,
                # one per tile pitch, nearest to where the tile stripe was (Uri:
                # any number of full-height power pins is fine).  The rows above /
                # below the macro get their rail vias back on the new stripes.
                x0, x1 = ib.xMin(), ib.xMax()
                columns = []                    # (xmin, xmax) of the macro's pin columns of this polarity
                for pin_name in SRAM_PINS[net_name]:
                    mterm = master.findMTerm(pin_name)
                    if mterm is None:
                        continue
                    for mpin in mterm.getMPins():
                        for box in mpin.getGeometry():
                            if box.getTechLayer().getName() != layer:
                                continue
                            columns.append((ox + box.xMin(), ox + box.xMax()))
                # distinct column x ranges (VDD and VDDARRAY share columns)
                columns = sorted(set(columns))
                if not columns:
                    print(f"[WARNING] {inst.getName()}: no {net_name} columns on {layer}")
                    continue
                # any stripe that overlaps the footprint, including one straddling
                # the macro edge (pdngen leaves a partial-height stub of those)
                crossing = [b for b in stripes if b.xMax() > x0 and b.xMin() < x1]
                targets = sorted(set((b.xMin() + b.xMax()) / 2 for b in crossing))
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
                used = set()
                for tx in targets:
                    def clear(c):
                        return all(c[1] + 0.5 * dbu < px0 or c[0] - 0.5 * dbu > px1 for (px0, px1) in pin_xs) \
                            and clear_of_rails(c[0], c[1], net_name)
                    cands = [c for c in columns if c not in used and clear(c)]
                    if not cands:
                        print(f"[WARNING] {inst.getName()}: no free {net_name} column for the stripe at x={tx/dbu:.2f}")
                        continue
                    c = min(cands, key=lambda c: abs((c[0] + c[1]) / 2 - tx))
                    used.add(c)
                    shift = ((c[0] + c[1]) / 2 - tx) / dbu
                    if abs(shift) > 0.05:
                        print(f"[INFO] {inst.getName()}: {net_name} stripe at x={tx/dbu:.2f} moved {shift:+.2f} um onto a column")
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
                print(f"[INFO] {inst.getName()}: {net_name}: {removed} tile stripes replaced by {len(used)} on the macro's tracks "
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


if __name__ == "__main__":
    extend()
