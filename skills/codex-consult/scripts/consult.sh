#!/usr/bin/env bash
#
# Run OpenAI Codex as a read-only peer reviewer and save its report.
#
#   consult.sh <topic-slug> <prompt-file>
#
# The prompt file holds the full consultation prompt (see ../references/
# templates.md). Codex runs in --sandbox read-only and only ever prints its
# report to stdout; THIS script saves it — the write happens outside Codex's
# sandbox, which is why read-only does not block it.
#
# Settings resolve per key: environment variable > per-machine config file
# (${XDG_CONFIG_HOME:-~/.config}/codex-consult/config, written by
# ./configure.sh) > built-in default.
#
#   env var                config key  default
#   CODEX_CONSULT_DIR      dir         ~/Documents/codex-consult
#   CODEX_CONSULT_MODEL    model       gpt-5.5
#   CODEX_CONSULT_EFFORT   effort      high
#   CODEX_CONSULT_TIMEOUT  timeout     600   (empty value disables the cap)
#
set -uo pipefail

usage() { echo "usage: consult.sh <topic-slug> <prompt-file>" >&2; exit 2; }
[ $# -eq 2 ] || usage

SLUG="$1"; PROMPT_FILE="$2"
[[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "error: topic-slug must be kebab-case (got: $SLUG)" >&2; exit 2; }
[ -r "$PROMPT_FILE" ] || { echo "error: cannot read prompt file: $PROMPT_FILE" >&2; exit 2; }
command -v codex >/dev/null 2>&1 || { echo "error: codex CLI not found — install it and run 'codex login'" >&2; exit 127; }

# Per-machine config (written by ./configure.sh); env vars override it.
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/codex-consult/config"
cfg() { [ -r "$CONFIG_FILE" ] && sed -n "s/^$1=//p" "$CONFIG_FILE" | tail -1 || true; }

DIR="${CODEX_CONSULT_DIR:-$(cfg dir)}";       DIR="${DIR:-$HOME/Documents/codex-consult}"
MODEL="${CODEX_CONSULT_MODEL:-$(cfg model)}"; MODEL="${MODEL:-gpt-5.5}"
EFFORT="${CODEX_CONSULT_EFFORT:-$(cfg effort)}"; EFFORT="${EFFORT:-high}"
# timeout: a SET-but-empty env var or config value means "no cap", so absence
# must be distinguished from emptiness at each layer.
if [ "${CODEX_CONSULT_TIMEOUT+x}" = x ]; then
  TIMEOUT_SECS="$CODEX_CONSULT_TIMEOUT"
elif [ -r "$CONFIG_FILE" ] && grep -q '^timeout=' "$CONFIG_FILE"; then
  TIMEOUT_SECS="$(cfg timeout)"
else
  TIMEOUT_SECS=600
fi

OUT="$DIR/$(date +%Y%m%d-%H%M%S)-$SLUG.md"
ERR="${OUT%.md}.err"
mkdir -p "$DIR"

CMD=(codex exec -m "$MODEL"
     --config model_reasoning_effort="$EFFORT"
     --sandbox read-only
     --skip-git-repo-check
     "$(cat "$PROMPT_FILE")")

# Hard cap via gtimeout (macOS: brew install coreutils) or timeout (Linux);
# degrades gracefully to uncapped if neither is installed.
if [ -n "$TIMEOUT_SECS" ]; then
  TIMEOUT_BIN="$(command -v gtimeout || command -v timeout || true)"
  [ -n "$TIMEOUT_BIN" ] && CMD=("$TIMEOUT_BIN" "$TIMEOUT_SECS" "${CMD[@]}")
fi

# </dev/null closes stdin so codex exec cannot hang waiting for "additional
# input" when run from a non-tty. stderr goes to a sibling .err file so the
# report stays clean but failures are never silently swallowed.
"${CMD[@]}" </dev/null 2>"$ERR" | tee "$OUT"
STATUS=$?

if [ "$STATUS" -eq 124 ]; then
  echo "error: codex timed out after ${TIMEOUT_SECS}s — retry or lower CODEX_CONSULT_EFFORT (stderr: $ERR)" >&2
  exit "$STATUS"
elif [ "$STATUS" -ne 0 ]; then
  echo "error: codex exited $STATUS — inspect $ERR (common: expired 'codex login', bad model name, malformed --config)" >&2
  exit "$STATUS"
fi

if [ ! -s "$OUT" ]; then
  echo "error: consultation report is empty — inspect $ERR" >&2
  exit 1
fi

[ -s "$ERR" ] || rm -f "$ERR"
echo ""
echo "saved: $OUT"
