---
name: skill-name-in-kebab-case
description: One sentence on what this does and when an agent should reach for it. Lead with concrete trigger words a user would actually type, since this line is the only thing the model sees before deciding to load the skill.
---

# Skill Name

## Overview

What this skill is for, in two or three sentences. Assume the reader is an
agent that has just loaded this file and needs to act.

## When to use

- **Situation.** What it looks like, and what to do.
- **Situation.** Same.

## Steps

1. First step.
2. Second step.
3. Third step.

## Notes

Anything that constrains the work — edge cases, things to avoid, how to verify
the result.

<!--
PORTABILITY (delete this comment in real skills)

Only `name` and `description` are supported by every harness. Keep the rest out
of frontmatter or it becomes Claude-only. See docs/portability.md.

  name         lowercase a-z, 0-9 and hyphens, <=64 chars, MUST match the
               directory name exactly
  description  <=1024 chars, single line

Bundle scripts and reference files alongside this one and refer to them by
RELATIVE path (./scripts/check.sh) — absolute paths break the moment the skill
is symlinked into a different harness's directory.
-->
