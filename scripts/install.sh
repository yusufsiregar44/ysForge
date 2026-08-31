#!/usr/bin/env bash
#
# Symlink ysForge skills and agents into every agent harness on this machine.
#
# Symlinks, not copies: edit a file in this repo and every harness sees the
# change immediately, with no build step and no drift.
#
#   ./scripts/install.sh              install into every harness detected
#   ./scripts/install.sh --dry-run    print what would happen, change nothing
#   ./scripts/install.sh --force      replace files this repo does not own
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
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
          say "  ! conflict  ${dest/#$HOME/\~} -> $current (foreign symlink, use --force)"
          conflicts=$((conflicts + 1)); return 0
        fi ;;
    esac
  elif [ -e "$dest" ]; then
    if [ "$FORCE" -eq 0 ]; then
      say "  ! conflict  ${dest/#$HOME/\~} (real file or directory, use --force)"
      conflicts=$((conflicts + 1)); return 0
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    say "  + would link ${dest/#$HOME/\~}"
  else
    mkdir -p "$dest_dir"
    rm -rf "$dest"
    ln -s "$src" "$dest"
    say "  + linked    ${dest/#$HOME/\~}"
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

say ""
say "linked $linked, unchanged $skipped, conflicts $conflicts"
[ "$conflicts" -gt 0 ] && exit 1
exit 0
