#!/usr/bin/env bash
# Build the GDS locally, same steps as the `gds` GitHub Action.
#   ./scripts/harden.sh              # LibreLane in its Docker image (default, same as CI)
#   ./scripts/harden.sh --no-docker  # use EDA tools on PATH (LibreLane Nix shell)
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$TT_ROOT"

[ -d tt ] || { echo "tt/ missing - run ./scripts/setup.sh first"; exit 1; }
[ -d "$PDK_ROOT/ihp-sg13cmos5l" ] || { echo "PDK missing at $PDK_ROOT - run ./scripts/setup.sh"; exit 1; }

EXTRA=""
[ "${1:-}" = "--no-docker" ] && EXTRA="--no-docker"

./tt/tt_tool.py --create-user-config $TT_ARGS
./tt/tt_tool.py --harden $TT_ARGS $EXTRA
./tt/tt_tool.py --print-warnings $TT_ARGS || true
./tt/tt_tool.py --print-stats $TT_ARGS || true
./tt/tt_tool.py --print-cell-category $TT_ARGS || true

# Copy netlist for gate-level simulation (make test-gl)
NETLIST=$(ls runs/wokwi/final/pnl/*.pnl.v 2>/dev/null | head -1 || true)
if [ -n "$NETLIST" ]; then
  cp "$NETLIST" test/gate_level_netlist.v
  echo "Gate-level netlist -> test/gate_level_netlist.v"
fi
echo "GDS: $(ls runs/wokwi/final/gds/*.gds)"
