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
