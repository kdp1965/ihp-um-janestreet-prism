"""
LibreLane plugin: extend the tile's Metal4 power stripes over the CFGMEM
macros (see odb_stripes.py for what the step does and why).

LibreLane imports every module on the Python path whose name starts with
``librelane_plugin_`` (librelane/plugins.py).  ``python -m librelane`` puts
the current directory on that path, and both the Tiny Tapeout GDS action
and ``make harden`` run it from the repository root, so this file is found
without installing anything.  src/config.json then inserts the step after
the PDN generator through ``meta.substituting_steps``:

    "meta": { "substituting_steps": { "+OpenROAD.GeneratePDN": "Project.ExtendPowerStripes" } }

flow.py uses the same step class for the local flow.
"""
import os

from librelane.steps import Step
from librelane.steps.odb import OdbpyStep
from librelane.state import DesignFormat
from librelane.config import Variable
from typing import Optional
from librelane.common import Path
from decimal import Decimal

HERE = os.path.dirname(os.path.abspath(__file__))


@Step.factory.register()
class ExtendPowerStripes(OdbpyStep):
    id = "Project.ExtendPowerStripes"
    name = "Extend Power Stripes Over Macros"

    def get_script_path(self):
        return os.path.join(HERE, "odb_stripes.py")

    config_vars = [
        Variable("EXTEND_STRIPES_LAYER", str, "The tile's vertical single-layer PDN layer (Metal4 on the CMOS5L tile, TopMetal1 on the sg13g2 tile).", default="Metal4"),
        Variable("EXTEND_STRIPES_SRAM_LAYER", Optional[str], "Layer of the IHP SRAM power columns when it differs from the stripe layer; the column stripes then get via stacks down to it.", default=None),
        Variable("EXTEND_STRIPES_CLEARANCE", Decimal, "Spacing kept between a drawn stripe and the other net's macro rails or tile pins on the stripe layer.", units="µm", default=Decimal("0.24")),
        Variable("EXTEND_STRIPES_STACK_PITCH", Decimal, "Spacing of the via stacks along an SRAM power column.", units="µm", default=Decimal("10")),
        Variable("EXTEND_STRIPES_PIN_FACE_MARGIN", Decimal, "No rail via stack within this distance of a macro edge that carries pins (the stack would block the pins' escape); 0 leaves pdngen's stacks alone.", units="µm", default=Decimal("3")),
        Variable("EXTEND_STRIPES_SRAM_ALL_COLUMNS", bool, "Put a stripe on every legal supply column of an IHP SRAM rather than only the ones the tile grid and the per-region minimum need.", default=False),
        Variable("EXTEND_STRIPES_SRAM_ARRAY_EVERY_OTHER", bool, "In each bit-cell array of an IHP SRAM, add a VPWR/VGND stripe pair on every other available pair position (the grid's pairs stay; the macro's standard-cell band is left as the grid gives it).  Not with EXTEND_STRIPES_SRAM_ALL_COLUMNS.", default=False),
    ]

    def get_command(self):
        cmd = super().get_command() + [
            "--layer", self.config["EXTEND_STRIPES_LAYER"],
            "--clearance", str(self.config["EXTEND_STRIPES_CLEARANCE"]),
            "--stack-pitch", str(self.config["EXTEND_STRIPES_STACK_PITCH"]),
            "--pin-face-margin", str(self.config["EXTEND_STRIPES_PIN_FACE_MARGIN"]),
        ]
        if self.config.get("EXTEND_STRIPES_SRAM_LAYER"):
            cmd += ["--sram-layer", self.config["EXTEND_STRIPES_SRAM_LAYER"]]
        cmd += ["--sram-all-columns" if self.config["EXTEND_STRIPES_SRAM_ALL_COLUMNS"] else "--sram-grid-columns"]
        if self.config["EXTEND_STRIPES_SRAM_ARRAY_EVERY_OTHER"]:
            cmd += ["--sram-array-every-other"]
        return cmd


# --- one antenna diode on every signal input pin of the IHP SRAMs (their LEF
# has no antenna data, so the rule-based repair cannot see those nets), then a
# detailed placement to legalise them.  Inserted before the first global
# routing (meta.substituting_steps "+OpenROAD.ResizerTimingPostCTS") so that
# single routing pass covers the diodes; the antenna repair later works
# incrementally on those routes and needs no extra global-routing pass.
from typing import List  # noqa: E402

from librelane.steps.step import CompositeStep  # noqa: E402
from librelane.steps.openroad import DetailedPlacement  # noqa: E402


# --- placement keep-outs at the CFGMEM mouths (odb_keepouts.py): the rows just
# outside each column's tile-facing edge, at the height of the gap between the
# two macros of a pair, capped to a low cell density (or blocked) before global
# placement, so the nets crossing into the macro pin rows find free Metal2
# tracks there.  Inserted after the macro placement
# (meta.substituting_steps "+Odb.ManualMacroPlacement").
from decimal import Decimal  # noqa: E402

from librelane.config import Variable  # noqa: E402


@Step.factory.register()
class MouthKeepouts(OdbpyStep):
    id = "Project.MouthKeepouts"
    name = "Placement Keep-outs at the Macro Mouths"

    config_vars = [
        Variable("MOUTH_KEEPOUT_WIDTH", Decimal, "Keep-out width outward from a CFGMEM column's tile-facing edge.", units="µm", default=60),
        Variable("MOUTH_KEEPOUT_MARGIN", Decimal, "How far the keep-out extends into each macro's height beyond the gap.", units="µm", default=20),
        Variable("MOUTH_KEEPOUT_MAX_DENSITY", Decimal, "Cell density cap of the soft blockage; 0 makes it a hard blockage.", default=Decimal("0.25")),
        Variable("MOUTH_KEEPOUT_MACRO_PREFIX", str, "Master-name prefix of the macros forming the columns.", default="CFGMEM"),
        Variable("MOUTH_KEEPOUT_INWARD", Decimal, "Extension of the keep-out inward from the column edge, over the gap between the two macros.", units="µm", default=0),
    ]

    def get_script_path(self):
        return os.path.join(HERE, "odb_keepouts.py")

    def get_command(self) -> List[str]:
        return super().get_command() + [
            "--macro-prefix", self.config["MOUTH_KEEPOUT_MACRO_PREFIX"],
            "--width", str(self.config["MOUTH_KEEPOUT_WIDTH"]),
            "--margin", str(self.config["MOUTH_KEEPOUT_MARGIN"]),
            "--max-density", str(self.config["MOUTH_KEEPOUT_MAX_DENSITY"]),
            "--inward", str(self.config["MOUTH_KEEPOUT_INWARD"]),
        ]


@Step.factory.register()
class AnchorSequential(OdbpyStep):
    """Pins the flops and latches where an earlier run had them (a
    tools/seq_placement.py table keyed by RTL name) before global placement,
    so a good draw's register skeleton is reused; new registers place
    freely.  Inserted right before global placement, after the rows are cut,
    the taps and the PDN are in, with meta.substituting_steps
    "+Odb.AddRoutingObstructions": "Project.AnchorSequential": any earlier
    and cut_rows slices the rows around every pinned (fixed) cell."""
    id = "Project.AnchorSequential"
    name = "Anchor the Registers to a Reference Placement"

    config_vars = ANCHOR_VARS = [
        Variable("ANCHOR_SEQ_TABLE", Optional[Path], "tools/seq_placement.py JSON of the run whose register placement is reused; unset = nothing pinned.", default=None),
        Variable("ANCHOR_SEQ_STATUS", str, "Placement status of the pinned registers: FIRM (DEF FIXED, the placers leave them) or PLACED (a starting point only).", default="FIRM"),
        Variable("ANCHOR_CELLS_TABLE", Optional[Path], "odb_anchor_cells.py --dump graph of the run whose placement is reused: registers by name AND combinational cells by structure; takes precedence over ANCHOR_SEQ_TABLE.", default=None),
        Variable("ANCHOR_CELLS_ROUNDS", int, "Neighbourhood radius (hops) of the structural matching's local pass.", default=3),
    ]

    def get_script_path(self):
        if self.config["ANCHOR_CELLS_TABLE"] is not None:
            return os.path.join(HERE, "odb_anchor_cells.py")
        return os.path.join(HERE, "odb_anchor_seq.py")

    def get_command(self) -> List[str]:
        if self.config["ANCHOR_CELLS_TABLE"] is not None:
            return super().get_command() + [
                "--table", str(self.config["ANCHOR_CELLS_TABLE"]),
                "--status", self.config["ANCHOR_SEQ_STATUS"],
                "--rounds", str(self.config["ANCHOR_CELLS_ROUNDS"]),
                "--report", os.path.join(self.step_dir, "anchor_pairs.json"),
            ]
        return super().get_command() + [
            "--table", str(self.config["ANCHOR_SEQ_TABLE"]),
            "--status", self.config["ANCHOR_SEQ_STATUS"],
        ]

    def run(self, state_in, **kwargs):
        if self.config["ANCHOR_SEQ_TABLE"] is None and self.config["ANCHOR_CELLS_TABLE"] is None:
            return {}, {}
        return super().run(state_in, **kwargs)


@Step.factory.register()
class ReleaseAnchors(OdbpyStep):
    """Sets the cells Project.AnchorSequential pinned back to PLACED right
    after global placement ("+OpenROAD.GlobalPlacement":
    "Project.ReleaseAnchors"): FIRM only has to steer the global placer, and
    left on it breaks the resizers' in-place upsizing (DPL-0033)."""
    id = "Project.ReleaseAnchors"
    name = "Release the Anchored Cells"
    config_vars = AnchorSequential.config_vars

    def get_script_path(self):
        return os.path.join(HERE, "odb_anchor_release.py")

    def run(self, state_in, **kwargs):
        if self.config["ANCHOR_SEQ_TABLE"] is None and self.config["ANCHOR_CELLS_TABLE"] is None:
            return {}, {}
        return super().run(state_in, **kwargs)


def merge_art(gds_in, gds_out, info):
    """The art cell (tools/chip_art.py) placed at its die origin in a copy of
    a GDS view.  Returns the number of Metal4 polygons added."""
    import klayout.db as kdb
    ly = kdb.Layout()
    ly.read(str(gds_in))
    top = ly.top_cell()                    # before the art cell exists (a second top until it is placed)
    art = kdb.Layout()
    art.read(str(info["gds"]))
    src = art.cell(info["cell"])
    if src is None:
        raise ValueError(f"cell {info['cell']} not in {info['gds']}")
    dst = ly.create_cell(info["cell"])
    dst.copy_tree(src)
    ox, oy = (int(round(v / ly.dbu)) for v in info["origin"])
    top.insert(kdb.CellInstArray(dst.cell_index(), kdb.Trans(kdb.Vector(ox, oy))))
    ly.write(str(gds_out))
    return dst.shapes(ly.layer(50, 0)).size()


def patch_lef(lef_in, lef_out, design, box):
    """The art's box added to the tile LEF as a Metal4 obstruction, so the
    top-level router stays off it."""
    import re
    lines = open(lef_in).read().split("\n")
    rect = f"      LAYER Metal4 ;\n        RECT {box[0]:.3f} {box[1]:.3f} {box[2]:.3f} {box[3]:.3f} ;"
    obs = next((i for i, l in enumerate(lines) if re.match(r"^\s*OBS\s*$", l)), None)
    if obs is not None:
        end = next(i for i in range(obs + 1, len(lines)) if re.match(r"^\s*END\s*$", lines[i]))
        lines[end:end] = rect.split("\n")
    else:
        end = next(i for i, l in enumerate(lines) if re.match(rf"^END\s+{re.escape(design)}\s*$", l))
        lines[end:end] = ["  OBS"] + rect.split("\n") + ["  END"]
    with open(lef_out, "w") as f:
        f.write("\n".join(lines))


@Step.factory.register()
class ChipArt(Step):
    """Merges a Metal4-only art cell (tools/chip_art.py: a bitmap on a 0.6 um
    pixel grid that meets the Metal4 rules by construction) into every GDS
    view after stream-out and adds its box to the tile LEF as a Metal4
    obstruction, so the Tiny Tapeout top-level router stays off it.
    Inserted with "+Magic.WriteLEF": "Project.ChipArt", before the KLayout
    DRC, which therefore checks the art in place.  The art exists only in
    the GDS: not in the ODB, DEF or netlist (nothing for LVS to see), and the
    tile's own router was kept off the box with a ROUTING_OBSTRUCTIONS entry
    (the art.json "routing_obstruction")."""
    id = "Project.ChipArt"
    name = "Chip Art into the GDS and the LEF"
    inputs = [DesignFormat.GDS, DesignFormat.LEF]
    outputs = [DesignFormat.GDS, DesignFormat.KLAYOUT_GDS, DesignFormat.MAG_GDS, DesignFormat.LEF]

    config_vars = [
        Variable("CHIP_ART_JSON", Optional[Path], "tools/chip_art.py's art.json: the art GDS, its cell, its die origin and box; unset = no art.", default=None),
    ]

    def run(self, state_in, **kwargs):
        if self.config["CHIP_ART_JSON"] is None:
            return {}, {}
        import json as _json
        info = _json.load(open(self.config["CHIP_ART_JSON"]))
        design = self.config["DESIGN_NAME"]
        views = {}
        done = []
        for fmt in (DesignFormat.GDS, DesignFormat.KLAYOUT_GDS, DesignFormat.MAG_GDS):
            src = state_in.get(fmt.id)          # State.get takes the format's id, not the DesignFormat
            if src is None:
                continue
            out = os.path.join(self.step_dir, f"{design}.{fmt.extension}")
            n = merge_art(src, out, info)
            views[fmt] = Path(out)
            done.append(f"{fmt.extension}: {n} polygons")
        lef = state_in.get(DesignFormat.LEF.id)
        if lef is not None:
            out = os.path.join(self.step_dir, f"{design}.lef")
            patch_lef(lef, out, design, info["box"])
            views[DesignFormat.LEF] = Path(out)
            done.append("lef: Metal4 OBS added")
        with open(os.path.join(self.step_dir, "chip_art.log"), "w") as f:
            f.write(f"{info['cell']} at {info['origin']}, box {info['box']}: {'; '.join(done)}\n")
        return views, {}


@Step.factory.register()
class DropKeepouts(OdbpyStep):
    """Removes the mouth keep-outs after detailed routing is signed off and
    before fill insertion, so the filler can put decap in the freed rows
    (fill and decap carry no signal pins, so they cannot take back the
    Metal2 tracks the keep-outs protected).  Ported from the sg13g2 tree."""
    id = "Project.DropKeepouts"
    name = "Drop the Placement Keep-outs"

    def get_script_path(self):
        return os.path.join(HERE, "odb_keepout_drop.py")


@Step.factory.register()
class SramPinDiodePlacement(OdbpyStep):
    id = "Project.SramPinDiodePlacement"
    name = "Diodes on SRAM Input Pins"

    def get_script_path(self):
        return os.path.join(HERE, "odb_sram_diodes.py")

    def get_command(self) -> List[str]:
        cell, pin = self.config["DIODE_CELL"].split("/")
        return super().get_command() + ["--diode-cell", cell, "--diode-pin", pin, "--macro-prefix", "RM_IHPSG13"]


@Step.factory.register()
class DiodesOnSramPins(CompositeStep):
    id = "Project.DiodesOnSramPins"
    name = "Diodes on SRAM Pins"
    Steps = [SramPinDiodePlacement, DetailedPlacement]


# --- post-synthesis macro swap.  The RTL instantiates one macro module for a
# whole generate loop (every CFGMEMS_LEFT[*] macro is a CFGMEM_IHP_LEFT16), but
# one instance may need a physical variant with the same ports: a macro built
# for its spot, like CFGMEM_IHP_LEFT16_SRAM, whose Metal4 rails sit on the
# supply columns of the SRAM under CFGMEMS_LEFT[1].cfgmem_lo.  Selecting it in
# the RTL would change the synthesized netlist (renaming a module alone makes
# yosys renumber its internal names, and ABC's mapping can follow), and with
# it the placement.  This step edits the synthesized netlist instead: each
# instance in MACRO_CELL_SWAPS gets the listed master and nothing else
# changes.  Inserted right after synthesis (meta.substituting_steps
# "+Yosys.Synthesis"), ahead of the checks that match MACROS against the
# netlist.  Gate-level simulation then needs the new master's netlist too
# (macros/<master>/<master>.nl.v in test/test_basic.mk and test_prog.mk).
from typing import Dict, Tuple  # noqa: E402

from librelane.common import Path  # noqa: E402
from librelane.state import DesignFormat, State  # noqa: E402
from librelane.steps.step import StepError, ViewsUpdate, MetricsUpdate  # noqa: E402
from librelane.logging import info  # noqa: E402


@Step.factory.register()
class SwapMacroCells(Step):
    id = "Project.SwapMacroCells"
    name = "Swap Macro Cells"

    inputs = [DesignFormat.NETLIST, DesignFormat.JSON_HEADER]
    outputs = [DesignFormat.NETLIST, DesignFormat.JSON_HEADER]

    config_vars = [
        Variable(
            "MACRO_CELL_SWAPS",
            Optional[Dict[str, str]],
            "Macro instances whose master is replaced after synthesis: instance name "
            "(as in MACROS) -> the macro it becomes.  The new macro must be in MACROS with "
            "that instance, and must have every port the instance connects.",
            default=None,
        ),
    ]

    def run(self, state_in: State, **kwargs) -> Tuple[ViewsUpdate, MetricsUpdate]:
        swaps = self.config["MACRO_CELL_SWAPS"] or {}
        if not swaps:
            return {}, {}
        macros = self.config["MACROS"] or {}
        design = self.config["DESIGN_NAME"]
        netlist = open(str(state_in[DesignFormat.NETLIST])).read()
        header = _json.load(open(str(state_in[DesignFormat.JSON_HEADER])))
        cells = header["modules"][design]["cells"]
        for inst, master in swaps.items():
            macro = macros.get(master)
            if macro is None or inst not in macro.instances:
                raise StepError(f"MACRO_CELL_SWAPS: {master} must be in MACROS with {inst} among its instances")
            pattern = _re.compile(r"^(\s*)(\S+)(\s+\\" + _re.escape(inst) + r"\s+\()", _re.M)
            hits = list(pattern.finditer(netlist))
            if len(hits) != 1:
                raise StepError(f"MACRO_CELL_SWAPS: {len(hits)} instances named {inst} in the netlist")
            old = hits[0].group(2)
            if old not in macros:
                raise StepError(f"MACRO_CELL_SWAPS: {inst} is a {old}, which is not a macro in MACROS")
            body = netlist[hits[0].end():netlist.index(");", hits[0].end())]
            used = set(_re.findall(r"\.(\w+)\s*\(", body))
            pins = set()   # port names: a LEF lists bus pins bit by bit (A0[0] ...)
            for lef in macro.lef:
                for name in _re.findall(r"^\s*PIN\s+(\S+)", open(str(lef)).read(), _re.M):
                    pins.add(_re.sub(r"\\?\[.*$", "", name))
            if not used <= pins:
                raise StepError(f"MACRO_CELL_SWAPS: {master} has no port {sorted(used - pins)} for {inst}")
            netlist = netlist[:hits[0].start(2)] + master + netlist[hits[0].end(2):]
            if cells.get(inst, {}).get("type") != old:
                raise StepError(f"MACRO_CELL_SWAPS: {inst} is not a {old} cell of {design} in the JSON header")
            cells[inst]["type"] = master
            info(f"{inst}: {old} -> {master}")
        nl_out = os.path.join(self.step_dir, f"{design}.nl.v")
        json_out = os.path.join(self.step_dir, f"{design}.h.json")
        with open(nl_out, "w") as f:
            f.write(netlist)
        with open(json_out, "w") as f:
            _json.dump(header, f)
        return {DesignFormat.NETLIST: Path(nl_out), DesignFormat.JSON_HEADER: Path(json_out)}, {}


# --- netgen writes the IHP SRAM's power pin names (VDD!, VSS!, VDDARRAY!) into
# its LVS JSON with a stray backslash ("\VDD!"), which is not a valid JSON
# escape, and librelane.steps.netgen.LVS then dies in json.loads before the
# LVS checker runs.  Give that module a json namespace whose loads() doubles
# such backslashes first (the metrics only count entries; names do not matter).
import json as _json
import re as _re
import types as _types

import librelane.steps.netgen as _netgen

_BAD_ESCAPE = _re.compile(r'\\(\\|[^"\\/bfnrtu])')


def _repair_escapes(s):
    return _BAD_ESCAPE.sub(lambda m: '\\\\' if m.group(1) == '\\' else '\\\\' + m.group(1), s)


def _loads_repairing_escapes(s, *args, **kwargs):
    try:
        return _json.loads(s, *args, **kwargs)
    except _json.JSONDecodeError:
        return _json.loads(_repair_escapes(s), *args, **kwargs)


_netgen.json = _types.SimpleNamespace(
    loads=_loads_repairing_escapes, load=_json.load, dumps=_json.dumps, dump=_json.dump,
    JSONDecodeError=_json.JSONDecodeError,
)
