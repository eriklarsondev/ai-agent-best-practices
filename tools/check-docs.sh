#!/usr/bin/env bash
#
# Structural checks for the docs here. Deliberately no size ceilings — the
# discipline is "one topic per file, one hop from the index, an explicit
# trigger on every leaf", not a token count an agent has to track.
#
#   - every leaf says when to open it and when to skip it
#   - every relative link resolves (a broken link is a wasted read)
#   - the AGENTS.md index and the leaf files match, both directions

set -euo pipefail
cd "$(dirname "$0")/.."

findings=$(mktemp)
trap 'rm -f "$findings"' EXIT
note() { printf '  %s\n' "$1" >>"$findings"; }

echo 'Triggers  — every leaf declares Open when / Skip if'
while IFS= read -r f; do
  grep -q '^\*\*Open when:\*\*' "$f" || note "${f#./} — no 'Open when:'"
  grep -q '^\*\*Skip if:\*\*' "$f" || note "${f#./} — no 'Skip if:'"
done < <(find ./practices ./workflows ./reference ./repo -name '*.md' | sort)

echo 'Links     — every relative target exists'
while IFS= read -r f; do
  d=$(dirname "$f")
  while IFS= read -r l; do
    l=${l#](}
    l=${l%)}
    l=${l%%#*}
    case "$l" in http*| '') continue ;; esac
    [ -e "$d/$l" ] || note "${f#./} → $l"
  done < <(grep -o ']([^)]*)' "$f" || true)
done < <(find . -name '*.md' -not -path './.git/*' | sort)

echo 'Index     — AGENTS.md and the leaves match, both directions'
while IFS= read -r f; do
  grep -qF "($f)" AGENTS.md || note "$f — not in the AGENTS.md index"
done < <(ls practices/*.md workflows/*.md)

while IFS= read -r l; do
  [ -f "$l" ] || note "AGENTS.md → $l (no such file)"
done < <(grep -o '(\(practices\|workflows\|reference\|repo\)/[a-z-]*\.md)' AGENTS.md |
  tr -d '()' | sort -u)

echo
if [ -s "$findings" ]; then
  cat "$findings"
  echo
  echo 'FAIL'
  exit 1
fi
echo 'PASS'
