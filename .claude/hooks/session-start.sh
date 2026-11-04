#!/bin/bash
# Installs this repo's superpowers skills into ~/.claude/skills and injects
# the using-superpowers bootstrap, for Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

repo="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
dest="${HOME}/.claude/skills"
mkdir -p "$dest"

# Symlink each skill so it always tracks the checked-out repo. Leave any
# existing non-symlink skill of the same name alone.
for skill in "$repo"/skills/*/; do
  name="$(basename "$skill")"
  target="$dest/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skipping $name: $target exists and is not a symlink" >&2
    continue
  fi
  ln -sfn "${skill%/}" "$target"
done

# Emit the plugin's bootstrap context (using-superpowers) so skills
# auto-trigger. This is the hook's only stdout.
CLAUDE_PLUGIN_ROOT="$repo" "$repo/hooks/session-start"
