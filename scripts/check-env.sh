#!/usr/bin/env bash
# Report what is installed and validate the project configuration.
set -uo pipefail
source "$(dirname "$0")/env.sh"
cd "$TT_ROOT"

ok()   { printf "  [ok]   %s\n" "$1"; }
miss() { printf "  [miss] %s\n" "$1"; }

echo "Tools:"
for t in python3 iverilog yosys openroad magic klayout netgen verilator; do
  command -v "$t" >/dev/null && ok "$t" || miss "$t"
done
python -c "import cocotb" 2>/dev/null && ok "cocotb $(python -c 'import cocotb;print(cocotb.__version__)')" || miss "cocotb"
python -c "import librelane" 2>/dev/null && ok "librelane" || miss "librelane (needed for harden)"
[ -d tt ] && ok "tt-support-tools ($(git -C tt rev-parse --abbrev-ref HEAD 2>/dev/null))" || miss "tt-support-tools (tt/)"
[ -d "$PDK_ROOT/ihp-sg13cmos5l" ] && ok "PDK $(cat "$PDK_ROOT/ihp-sg13cmos5l/SOURCES" 2>/dev/null)" || miss "PDK at $PDK_ROOT"

echo "Project:"
grep -E '^\s*(tiles|top_module|clock_hz):' info.yaml | sed 's/^ */  /'
if [ -d tt ]; then
  ./tt/tt_tool.py --create-user-config $TT_ARGS && ok "info.yaml valid, src/user_config.json generated"
fi
