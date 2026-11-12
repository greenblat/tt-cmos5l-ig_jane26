# Shared settings for the Tiny Tapeout IHP SG13CMOS5L flow.
# Source this file:  source scripts/env.sh
# Versions mirror TinyTapeout/tt-gds-action@ihp-cmos5l so local results match CI.

TT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export TT_ROOT

export PDK="${PDK:-ihp-sg13cmos5l}"
export PDK_ROOT="${PDK_ROOT:-$HOME/ttsetup/pdk}"
export TT_VENV="${TT_VENV:-$HOME/ttsetup/venv}"

export TT_SUPPORT_TOOLS_REPO="https://github.com/TinyTapeout/tt-support-tools"
export TT_SUPPORT_TOOLS_BRANCH="ihp-sg13cmos5l"
export LIBRELANE_VERSION="3.1.0.dev3"
export IHP_PDK_REPO="https://github.com/IHP-GmbH/IHP-Open-PDK.git"
# IHP-Open-PDK dev branch, 2026-09-08
export IHP_PDK_REV="2bbec755dc67ca3db0261c3d6163e15735d66710"

# tt_tool.py flag for both IHP processes
export TT_ARGS="--ihp"

if [ -f "$TT_VENV/bin/activate" ]; then
  # shellcheck disable=SC1091
  source "$TT_VENV/bin/activate"
fi
