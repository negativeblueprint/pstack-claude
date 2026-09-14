#!/usr/bin/env bash
# Proves install.sh: fresh install, idempotent re-run, collision refusal, forced recovery.
# Installs into a temp directory. Never touches your real ~/.claude.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT
export CLAUDE_HOME="$sandbox"

expected_skills=$(find "$repo/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
expected_agents=$(find "$repo/agents" -name '*.md' | wc -l | tr -d ' ')
fail=0

check() {
	if [ "$2" = "$3" ]; then
		echo "  pass  $1 ($2)"
	else
		echo "  FAIL  $1: expected $3, got $2"
		fail=1
	fi
}

echo "fresh install"
out=$("$repo/install.sh")
check "skills on disk" "$(find "$sandbox/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" "$expected_skills"
check "agents on disk" "$(find "$sandbox/agents" -name '*.md' | wc -l | tr -d ' ')" "$expected_agents"
check "every skill has SKILL.md" "$(find "$sandbox/skills" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -print | wc -l | tr -d ' ')" "$expected_skills"
check "reported added" "$(echo "$out" | sed -n 's/.*skills: \([0-9]*\) added.*/\1/p')" "$expected_skills"

echo "idempotent re-run"
out=$("$repo/install.sh")
check "reported added" "$(echo "$out" | sed -n 's/.*skills: \([0-9]*\) added.*/\1/p')" "0"
check "reported current" "$(echo "$out" | sed -n 's/.*added or updated, \([0-9]*\) already current.*/\1/p')" "$expected_skills"

echo "collision refusal"
echo "user's own skill" >> "$sandbox/skills/how/SKILL.md"
if "$repo/install.sh" >/dev/null 2>&1; then
	echo "  FAIL  overwrote a differing skill without --force"
	fail=1
else
	echo "  pass  refused to overwrite a differing skill"
fi
check "user content preserved" "$(grep -c "user's own skill" "$sandbox/skills/how/SKILL.md")" "1"

echo "forced recovery"
"$repo/install.sh" --force >/dev/null
check "user content replaced" "$(grep -c "user's own skill" "$sandbox/skills/how/SKILL.md" || true)" "0"
check "still complete" "$(find "$sandbox/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" "$expected_skills"

echo "documented counts"
for doc in README.md PORTING.md; do
	for claimed in $(grep -oE '[0-9]+ skills' "$repo/$doc" | grep -oE '^[0-9]+' | sort -u); do
		check "$doc skill count" "$claimed" "$expected_skills"
	done
	for claimed in $(grep -oE '[0-9]+ agents' "$repo/$doc" | grep -oE '^[0-9]+' | sort -u); do
		check "$doc agent count" "$claimed" "$expected_agents"
	done
done

echo
[ "$fail" -eq 0 ] && echo "all checks passed" || { echo "checks failed"; exit 1; }
