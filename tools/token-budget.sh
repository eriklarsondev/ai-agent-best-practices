#!/usr/bin/env bash
#
# Estimates the context cost of every doc here and fails if one is over budget.
# A reference about token discipline that is expensive to load refutes itself.
#
# Estimate is bytes/4. Real tokenizers vary by roughly ±20% on markdown, so treat
# this as a guardrail, not a measurement.

set -euo pipefail
cd "$(dirname "$0")/.."

budget_for() {
  case "$1" in
    # Higher than the ~1000 this repo prescribes for a *project* AGENTS.md
    # (repo/writing-agents-md.md). This file is a different artifact: the full
    # operating ruleset plus the load-on-demand index for 37 leaves. Raise it
    # only after confirming nothing inside is duplicated in a leaf.
    ./AGENTS.md)     echo 2300 ;;
    ./CLAUDE.md)     echo  120 ;;
    ./README.md)     echo 1200 ;;
    ./boundaries.md) echo 1500 ;;
    ./practices/*)   echo 1100 ;;
    ./workflows/*)   echo 1000 ;;
    ./reference/*)   echo 1400 ;;
    ./repo/*)        echo 1100 ;;
    ./templates/*)   echo  700 ;;
    *)               echo    0 ;;  # 0 = advisory, reported but never fails
  esac
}

tokens_in() { echo $(( $(wc -c < "$1") / 4 )); }

fail=0
total=0

printf '%-42s %7s %7s  %s\n' FILE TOKENS BUDGET STATUS
printf '%-42s %7s %7s  %s\n' '------------------------------------------' ------ ------ ------

while IFS= read -r f; do
  t=$(tokens_in "$f")
  b=$(budget_for "$f")
  total=$(( total + t ))

  if [ "$b" -eq 0 ]; then
    shown='-'; status='-'
  elif [ "$t" -gt "$b" ]; then
    shown="$b"; status='OVER'; fail=1
  else
    shown="$b"; status='ok'
  fi

  printf '%-42s %7s %7s  %s\n' "${f#./}" "$t" "$shown" "$status"
done < <(find . -name '*.md' -not -path './.git/*' | sort)

always=$(( $(tokens_in ./AGENTS.md) + $(tokens_in ./CLAUDE.md) ))

echo
printf 'Always loaded (AGENTS.md + CLAUDE.md): %s tokens\n' "$always"
printf 'Whole repo if fully read:              %s tokens\n' "$total"
echo
if [ "$fail" -ne 0 ]; then
  echo 'FAIL — split the oversized file, or move detail into a leaf that loads on demand.'
else
  echo 'PASS'
fi

exit "$fail"
