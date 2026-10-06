#!/bin/bash
input=$(cat)

IFS=$'\x1f' read -r DIR MODEL PCT ADD DEL < <(
  echo "$input" | jq -r '[
    (.workspace.current_dir // ""),
    (.model.display_name // "claude"),
    ((.context_window.used_percentage // 0) | floor | tostring),
    (.cost.total_lines_added // 0 | tostring),
    (.cost.total_lines_removed // 0 | tostring)
  ] | join("\u001f")'
)

BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)

if   [ "$PCT" -ge 80 ]; then C='\033[31m'
elif [ "$PCT" -ge 50 ]; then C='\033[33m'
else C='\033[32m'; fi

W=20
F=$((PCT * W / 100)); [ "$F" -gt "$W" ] && F=$W
FULL=████████████████████; EMPTY=░░░░░░░░░░░░░░░░░░░░
BAR="${C}${FULL:0:F}\033[90m${EMPTY:0:W-F}"

printf '\033[1;33m%s\033[0m' "${DIR##*/}"
[ -n "$BRANCH" ] && printf ' \033[32m(%s)\033[0m' "$BRANCH"
printf " \033[90m|\033[0m %b ${C}%s%%\033[0m" "$BAR" "$PCT"
printf ' \033[90m|\033[0m \033[32m+%s\033[0m \033[31m-%s\033[0m' "$ADD" "$DEL"
printf ' \033[90m|\033[0m \033[35m%s\033[0m' "$MODEL"

c="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/cache"
for pl in "ponytail/ponytail/*/hooks/ponytail-statusline.sh|36" "caveman/caveman/*/src/hooks/caveman-statusline.sh|33"; do
  f=$(ls -d $c/${pl%|*} 2>/dev/null | sort -V | tail -1)
  [ -n "$f" ] || continue
  b=$(printf '%s' "$input" | bash "$f" | sed 's/\x1b\[[0-9;]*m//g; s/[][]//g' | tr 'A-Z' 'a-z')
  [ -n "$b" ] && printf ' \033[90m|\033[0m \033[%sm%s\033[0m' "${pl#*|}" "$b"
done
printf '\n'
