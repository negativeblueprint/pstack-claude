#!/usr/bin/env bash
# Install pstack skills and agents into your Claude Code config.
# Re-running converges to the same state. Set CLAUDE_HOME to install elsewhere.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${CLAUDE_HOME:-$HOME/.claude}"
force=0
[ "${1:-}" = "--force" ] && force=1

installed=0 skipped=0
collisions=()

for src in "$repo"/skills/*/; do
	name="$(basename "$src")"
	dst="$target/skills/$name"
	if [ -d "$dst" ]; then
		if diff -rq "$src" "$dst" >/dev/null 2>&1; then
			skipped=$((skipped + 1))
			continue
		fi
		if [ "$force" -eq 0 ]; then
			collisions+=("$name")
			continue
		fi
	fi
	mkdir -p "$target/skills"
	rm -rf "$dst"
	cp -r "$src" "$dst"
	installed=$((installed + 1))
done

if [ ${#collisions[@]} -gt 0 ]; then
	echo "Refusing to overwrite ${#collisions[@]} existing skill(s) that differ from ours:" >&2
	printf '  %s\n' "${collisions[@]}" >&2
	echo >&2
	echo "These may be your own skills. Back them up, then re-run with --force." >&2
	exit 1
fi

mkdir -p "$target/agents"
for src in "$repo"/agents/*.md; do
	cp "$src" "$target/agents/$(basename "$src")"
done

echo "pstack installed to $target"
echo "  skills: $installed added or updated, $skipped already current"
echo "  agents: $(find "$repo/agents" -name '*.md' | wc -l | tr -d ' ')"
echo
echo "Restart Claude Code, then run /setup-pstack"
