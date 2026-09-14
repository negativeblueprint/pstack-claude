#!/usr/bin/env bash
# Proves install.sh: fresh install, idempotent re-run, collision refusal, forced recovery.
# Then gates the tree itself: skill manifest, relative links, and documented counts.
# Installs into a temp directory. Never touches your real ~/.claude.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT
export CLAUDE_HOME="$sandbox"

expected_skills=$(find "$repo/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
expected_agents=$(find "$repo/agents" -name '*.md' | wc -l | tr -d ' ')
expected_playbooks=$(find "$repo/skills/poteto-mode/playbooks" -name '*.md' | wc -l | tr -d ' ')
expected_principles=$(find "$repo/skills" -mindepth 1 -maxdepth 1 -type d -name 'principle-*' | wc -l | tr -d ' ')
fail=0

check() {
	if [ "$2" = "$3" ]; then
		echo "  pass  $1 ($2)"
	else
		echo "  FAIL  $1: expected $3, got $2"
		fail=1
	fi
}

link_targets() {
	grep -oE '\]\([^) ]+\)|src="[^"]+"' "$1" | sed -E 's/^\]\(//; s/\)$//; s/^src="//; s/"$//' | sort -u
}

resolves() {
	# No slash and no dot means a template placeholder like (url), not a path.
	case "$2" in
		"" | http* | mailto:* | '#'*) return 0 ;;
		*/* | *.*) ;;
		*) return 0 ;;
	esac
	[ -e "$1/${2%%#*}" ]
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

echo "skill manifest"
manifest_bad=0
for dir in "$repo"/skills/*/; do
	slug="$(basename "$dir")"
	declared="$(sed -n 's/^name: *//p' "$dir/SKILL.md" | head -1 | tr -d '\042\047')"
	[ "$declared" = "$slug" ] || { echo "  FAIL  $slug declares name '$declared'"; manifest_bad=1; }
	grep -q '^description:' "$dir/SKILL.md" || { echo "  FAIL  $slug has no description"; manifest_bad=1; }
	case "$slug" in
		principle-*)
			grep -q "(\*\*$slug\*\*)" "$repo/skills/poteto-mode/SKILL.md" ||
				{ echo "  FAIL  $slug is not in poteto-mode's principles index"; manifest_bad=1; } ;;
	esac
done
if [ "$manifest_bad" -eq 0 ]; then
	echo "  pass  every skill names itself and every principle leaf is indexed"
else
	fail=1
fi

echo "relative links"
link_bad=0
while IFS= read -r doc; do
	dir="$(dirname "$doc")"
	rel="${doc#"$repo"/}"
	while IFS= read -r target; do
		resolves "$dir" "$target" ||
			{ echo "  FAIL  $rel points at missing $target"; link_bad=1; }
	done < <(link_targets "$doc")
done < <(find "$repo" -name '*.md' -not -path '*/.git/*' -not -name 'README.upstream.md')
if [ "$link_bad" -eq 0 ]; then
	echo "  pass  every relative link and image resolves"
else
	fail=1
fi

echo "meowl-mode stands alone"
solo="$sandbox/standalone"
mkdir -p "$solo"
cp -r "$repo/skills/meowl-mode" "$solo/"
solo_bad=0
while IFS= read -r target; do
	resolves "$solo/meowl-mode" "$target" ||
		{ echo "  FAIL  meowl-mode reaches outside itself for $target"; solo_bad=1; }
done < <(link_targets "$solo/meowl-mode/SKILL.md")
if [ "$solo_bad" -eq 0 ]; then
	echo "  pass  copied alone into an empty tree, nothing dangles"
else
	fail=1
fi

echo "documented counts"
counts_bad=0
while IFS= read -r doc; do
	rel="${doc#"$repo"/}"
	for pair in "skills:$expected_skills" "agents:$expected_agents" \
		"playbooks:$expected_playbooks" "principles:$expected_principles" \
		"principle leaves:$expected_principles"; do
		noun="${pair%:*}"
		expected="${pair##*:}"
		for claimed in $(grep -oE "[0-9]+ $noun" "$doc" | grep -oE '^[0-9]+' | sort -u); do
			[ "$claimed" = "$expected" ] ||
				{ echo "  FAIL  $rel claims $claimed $noun, actual $expected"; counts_bad=1; }
		done
	done
done < <(find "$repo" -name '*.md' -not -path '*/.git/*' -not -name 'README.upstream.md')
if [ "$counts_bad" -eq 0 ]; then
	echo "  pass  every documented count matches the tree"
else
	fail=1
fi

echo
[ "$fail" -eq 0 ] && echo "all checks passed" || { echo "checks failed"; exit 1; }
