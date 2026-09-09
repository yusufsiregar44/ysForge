#!/usr/bin/env bash
#
# Configure this machine's codex-consult installation.
#
#   configure.sh --dir <path>          where consultation reports are saved
#   configure.sh --model <name>        codex model        (default gpt-5.5)
#   configure.sh --effort <level>      reasoning effort   (default high)
#   configure.sh --timeout <secs>      hard cap; "" disables (default 600)
#   configure.sh --show                print the effective configuration
#
# Settings persist in ${XDG_CONFIG_HOME:-~/.config}/codex-consult/config as
# KEY=VALUE lines, per machine — the skill files stay identical everywhere.
# Environment variables (CODEX_CONSULT_*) still override at run time.
#
set -euo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/codex-consult/config"

cfg() { [ -r "$CONFIG_FILE" ] && sed -n "s/^$1=//p" "$CONFIG_FILE" | tail -1 || true; }

set_key() {  # set_key <key> <value>
  mkdir -p "$(dirname "$CONFIG_FILE")"
  touch "$CONFIG_FILE"
  grep -v "^$1=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
  printf '%s=%s\n' "$1" "$2" >> "$CONFIG_FILE.tmp"
  mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  echo "set $1=$2"
}

show() {
  echo "config file: $CONFIG_FILE $([ -r "$CONFIG_FILE" ] && echo '(present)' || echo '(absent)')"
  echo "effective settings (env > config > default):"
  printf '  reports dir: %s\n' "${CODEX_CONSULT_DIR:-$(cfg dir)}"
  printf '  model:       %s\n' "${CODEX_CONSULT_MODEL:-$(cfg model)}"
  printf '  effort:      %s\n' "${CODEX_CONSULT_EFFORT:-$(cfg effort)}"
  printf '  timeout:     %s\n' "${CODEX_CONSULT_TIMEOUT-$(cfg timeout)}"
  echo "  (blank = built-in default: ~/Documents/codex-consult, gpt-5.5, high, 600)"
}

[ $# -gt 0 ] || { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      [ $# -ge 2 ] || { echo "error: --dir needs a path" >&2; exit 2; }
      # store absolute, ~-expanded path so it works from any cwd
      raw="$2"; raw="${raw/#\~/$HOME}"
      case "$raw" in /*) abs="$raw" ;; *) abs="$PWD/$raw" ;; esac
      set_key dir "$abs"; shift 2 ;;
    --model)   [ $# -ge 2 ] || { echo "error: --model needs a value" >&2; exit 2; }
               set_key model "$2"; shift 2 ;;
    --effort)  [ $# -ge 2 ] || { echo "error: --effort needs a value" >&2; exit 2; }
               set_key effort "$2"; shift 2 ;;
    --timeout) [ $# -ge 2 ] || { echo "error: --timeout needs a value (\"\" disables)" >&2; exit 2; }
               set_key timeout "$2"; shift 2 ;;
    --show)    show; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
