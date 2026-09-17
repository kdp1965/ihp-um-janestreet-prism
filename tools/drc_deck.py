"""
The real CMOS5L KLayout DRC deck for local sign-off.

Tiny Tapeout's pinned ihp-sg13cmos5l snapshot ships a trimmed KLayout deck
that executes no rules; the IHP-Open-PDK dev branch's vendored copy has the
full deck (333 rules on this tile).  src/config.json points KLAYOUT_DRC_RUNSET
at the PDK's own deck so the CI can resolve it; local runs add the override
below when the dev deck exists ($PDK_ROOT/ihp-open-pdk-dev/..., or
LIBRELANE_DRC_DECK).  Prints the `-c` argument for ad-hoc command lines:

    python -m librelane $(python3 tools/drc_deck.py) ... src/config_merged.json
"""
import os

DEV_DECK = os.environ.get("LIBRELANE_DRC_DECK") or os.path.join(
    os.environ.get("PDK_ROOT", os.path.expanduser("~/projects/fossi")),
    "ihp-open-pdk-dev", "ihp-sg13cmos5l", "libs.tech", "klayout", "tech", "drc", "ihp-sg13cmos5l.drc",
)


def override():
    """['KLAYOUT_DRC_RUNSET=<deck>'] when the full deck is available here, else []"""
    return [f"KLAYOUT_DRC_RUNSET={DEV_DECK}"] if os.path.exists(DEV_DECK) else []


if __name__ == "__main__":
    print(" ".join(f"-c {o}" for o in override()))
