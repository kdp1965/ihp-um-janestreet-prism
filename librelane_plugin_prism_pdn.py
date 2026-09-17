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

HERE = os.path.dirname(os.path.abspath(__file__))


@Step.factory.register()
class ExtendPowerStripes(OdbpyStep):
    id = "Project.ExtendPowerStripes"
    name = "Extend Power Stripes Over Macros"

    def get_script_path(self):
        return os.path.join(HERE, "odb_stripes.py")


# --- one antenna diode on every signal input pin of the IHP SRAMs (their LEF
# has no antenna data, so the rule-based repair cannot see those nets), then a
# detailed placement to legalise them.  Inserted before the first global
# routing (meta.substituting_steps "+OpenROAD.ResizerTimingPostCTS") so that
# single routing pass covers the diodes; the antenna repair later works
# incrementally on those routes and needs no extra global-routing pass.
from typing import List  # noqa: E402

from librelane.steps.step import CompositeStep  # noqa: E402
from librelane.steps.openroad import DetailedPlacement  # noqa: E402


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
