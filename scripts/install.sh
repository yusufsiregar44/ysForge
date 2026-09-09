#!/usr/bin/env bash
#
# Symlink ysForge skills, agents and hooks into every harness on this machine.
#
# Symlinks, not copies: edit a file in this repo and every harness sees the
# change immediately, with no build step and no drift.
#
#   ./scripts/install.sh                     install into every harness detected
#   ./scripts/install.sh --dry-run           print what would happen, change nothing
#   ./scripts/install.sh --force             replace files this repo does not own
#   ./scripts/install.sh --consult-dir PATH  set THIS machine's codex-consult
#                                            report directory (per-install config,
#                                            delegates to the skill's configure.sh)
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
FORCE=0
CONSULT_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --force)   FORCE=1; shift ;;
    --consult-dir)
      [ $# -ge 2 ] || { echo "error: --consult-dir needs a path" >&2; exit 2; }
      CONSULT_DIR="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

linked=0; skipped=0; conflicts=0

say() { printf '%s\n' "$*"; }

# link <source> <destination>
# Idempotent. Never clobbers anything this repo does not already own unless
# --force is passed.
link() {
  local src="$1" dest="$2" dest_dir
  dest_dir="$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      skipped=$((skipped + 1))
      return 0                                  # already correct
    fi
    case "$current" in
      "$REPO"/*) : ;;                           # ours, stale target - relink
      *)
        if [ "$FORCE" -eq 0 ]; then
          say "  ! conflict  ${dest/#$HOME/~} -> $current (foreign symlink, use --force)"
          conflicts=$((conflicts + 1)); return 0
        fi ;;
    esac
  elif [ -e "$dest" ]; then
    if [ "$FORCE" -eq 0 ]; then
      say "  ! conflict  ${dest/#$HOME/~} (real file or directory, use --force)"
      conflicts=$((conflicts + 1)); return 0
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    say "  + would link ${dest/#$HOME/~}"
  else
    mkdir -p "$dest_dir"
    rm -rf "$dest"
    ln -s "$src" "$dest"
    say "  + linked    ${dest/#$HOME/~}"
  fi
  linked=$((linked + 1))
}

# link_skills <target skills dir>   - one symlink per skill, so ysForge skills
#                                     coexist with skills from other sources
link_skills() {
  local target="$1" skill name
  for skill in "$REPO"/skills/*/; do
    [ -d "$skill" ] || continue
    [ -f "$skill/SKILL.md" ] || continue
    name="$(basename "$skill")"
    link "${skill%/}" "$target/$name"
  done
}

link_agents() {
  local target="$1" agent name
  for agent in "$REPO"/agents/*.md; do
    [ -e "$agent" ] || continue
    name="$(basename "$agent")"
    link "$agent" "$target/$name"
  done
}

link_hooks() {
  local target="$1" hook name
  for hook in "$REPO"/hooks/*.sh; do
    [ -e "$hook" ] || continue
    name="$(basename "$hook")"
    link "$hook" "$target/$name"
  done
}

# register_claude_hook <event> <matcher> <command> <status message>
#
# Adds one hook entry to ~/.claude/settings.json. Unlike everything else here a
# hook cannot be a symlink: settings.json is a single file holding per-machine
# settings this repo has no business owning, so the entry is merged in and every
# other key is left exactly as it was. Keyed on the command string, so re-runs
# are no-ops rather than duplicates.
register_claude_hook() {
  local event="$1" matcher="$2" cmd="$3" status="$4"
  local settings="$HOME/.claude/settings.json" tmp entry

  if ! command -v jq >/dev/null 2>&1; then
    say "  ! conflict  settings.json needs jq to merge $event/$matcher (install jq, or add the entry by hand — see docs/hooks.md)"
    conflicts=$((conflicts + 1))
    return 0
  fi

  if [ -e "$settings" ] && ! jq -e . "$settings" >/dev/null 2>&1; then
    say "  ! conflict  ${settings/#$HOME/~} is not valid JSON — fix it first, then re-run"
    conflicts=$((conflicts + 1))
    return 0
  fi

  if [ -f "$settings" ] && jq -e --arg e "$event" --arg c "$cmd" \
      '[.hooks[$e][]?.hooks[]?.command] | any(. == $c)' "$settings" >/dev/null 2>&1; then
    skipped=$((skipped + 1))                      # already registered
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    say "  + would register $event/$matcher in ${settings/#$HOME/~}"
    linked=$((linked + 1))
    return 0
  fi

  mkdir -p "$(dirname "$settings")"
  [ -f "$settings" ] || printf '{}\n' > "$settings"
  cp "$settings" "$settings.ysforge.bak"

  entry="$(jq -nc --arg c "$cmd" --arg s "$status" \
    '{type: "command", command: $c, statusMessage: $s}')"
  tmp="$(mktemp)"

  # Append into the existing matcher group when there is one, so the event does
  # not accumulate a second group with the same matcher.
  if jq --arg e "$event" --arg m "$matcher" --argjson entry "$entry" '
        .hooks //= {} | .hooks[$e] //= [] |
        if any(.hooks[$e][]; .matcher == $m)
        then .hooks[$e] = [ .hooks[$e][]
               | if .matcher == $m then .hooks += [$entry] else . end ]
        else .hooks[$e] += [{matcher: $m, hooks: [$entry]}]
        end
      ' "$settings" > "$tmp" && jq -e . "$tmp" >/dev/null 2>&1; then
    mv "$tmp" "$settings"
    say "  + registered $event/$matcher in ${settings/#$HOME/~}"
    linked=$((linked + 1))
  else
    rm -f "$tmp"
    say "  ! conflict  could not merge $event/$matcher into ${settings/#$HOME/~} (left unchanged)"
    conflicts=$((conflicts + 1))
  fi
}

say "ysForge  $REPO"
[ "$DRY_RUN" -eq 1 ] && say "(dry run - nothing will be written)"
say ""

# --- Vendor-neutral: read natively by Codex and pi -------------------------
# Always installed, even when neither CLI is present yet, so a harness added
# later picks these up with no extra step.
say "~/.agents  (vendor-neutral: Codex, pi)"
link_skills "$HOME/.agents/skills"

# --- Claude Code -----------------------------------------------------------
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  say ""
  say "~/.claude  (Claude Code)"
  link_skills "$HOME/.claude/skills"
  link_agents "$HOME/.claude/agents"
  link_hooks  "$HOME/.claude/hooks"
  register_claude_hook "PreToolUse" "Agent|Task" \
    "bash $HOME/.claude/hooks/no-nested-agents.sh" \
    "Enforcing max agent depth of 1"
fi

# --- pi --------------------------------------------------------------------
# pi also reads ~/.agents/skills, so only agents need a pi-specific link.
if [ -d "$HOME/.pi" ] || command -v pi >/dev/null 2>&1; then
  say ""
  say "~/.pi  (pi)"
  link_agents "$HOME/.pi/agent/agents"
fi

# --- Codex -----------------------------------------------------------------
# Skills come from ~/.agents/skills above. Codex has no verified custom-agent
# format yet; see docs/portability.md.
if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  say ""
  say "~/.codex  (Codex)"
  say "  = skills served from ~/.agents/skills; agents not yet supported"
fi

# --- Per-install configuration ----------------------------------------------
# Skill settings that differ per machine live outside the repo (see each
# skill's scripts/configure.sh); the symlinked skill files stay identical.
CONSULT_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/codex-consult/config"
if [ -n "$CONSULT_DIR" ]; then
  say ""
  say "codex-consult configuration"
  if [ "$DRY_RUN" -eq 1 ]; then
    say "  + would set reports dir to $CONSULT_DIR (in ${CONSULT_CFG/#$HOME/~})"
  else
    "$REPO/skills/codex-consult/scripts/configure.sh" --dir "$CONSULT_DIR" | sed 's/^/  + /'
  fi
elif [ -d "$REPO/skills/codex-consult" ] && [ ! -r "$CONSULT_CFG" ]; then
  say ""
  say "note: codex-consult reports default to ~/Documents/codex-consult on this"
  say "      machine — set a destination with: ./scripts/install.sh --consult-dir PATH"
fi

say ""
say "linked $linked, unchanged $skipped, conflicts $conflicts"
[ "$conflicts" -gt 0 ] && exit 1
exit 0
