#!/usr/bin/env bash
# SessionStart hook for Claude Code on the web.
# Installs this repo's skills and agents into the session's ~/.claude so they
# are available while you work, and installs shellcheck so the shell scripts
# here can be linted. Local sessions are left alone: install yourself there.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
	exit 0
fi

repo="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# The remote home is ephemeral and recreated per container, so the repo is the
# source of truth. --force only on the retry, so a real collision still shows
# up in the log before we overwrite it.
"$repo/install.sh" || "$repo/install.sh" --force

if ! command -v shellcheck >/dev/null 2>&1; then
	(apt-get update -qq && apt-get install -y --no-install-recommends shellcheck) \
		|| echo "session-start: shellcheck unavailable, skipping lint tooling" >&2
fi
