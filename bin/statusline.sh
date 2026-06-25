#!/usr/bin/env bash
# Claude Code status line
# Line 1: 📁 folder | 🌿 branch | 🤖 model
# Line 2: 🧠 ctx% [bar] | 5h: x% | 7d: y%
#
# Always split across two lines instead of relying on terminal soft-wrap —
# Claude Code's statusline UI does not wrap a single long line, it truncates it.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Git branch
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# Context window
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limits
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Progress bar (fixed 20 chars)
ctx_part=""
if [ -n "$used" ]; then
    used_int=$(printf "%.0f" "$used")
    bar_width=20
    filled=$(( used_int * bar_width / 100 ))
    [ "$filled" -gt "$bar_width" ] && filled=$bar_width
    empty=$(( bar_width - filled ))

    bar=""
    if [ "$filled" -gt 0 ]; then
        bar=$(printf '%*s' "$((filled - 1))" '' | tr ' ' '=')
        bar="${bar}>"
    fi
    bar="${bar}$(printf '%*s' "$empty" '')"

    ctx_part="🧠 ${used_int}% [${bar}]"
fi

git_part=""
[ -n "$branch" ] && git_part="🌿 ${branch}"

model_part=""
[ -n "$model" ] && model_part="🤖 ${model}"

limit_part=""
if [ -n "$five_hour" ]; then
    five_int=$(printf "%.0f" "$five_hour")
    limit_part="5h: ${five_int}%"
fi
if [ -n "$seven_day" ]; then
    seven_int=$(printf "%.0f" "$seven_day")
    limit_part="${limit_part:+${limit_part} | }7d: ${seven_int}%"
fi

# Line 1: identity (dir, branch, model)
line1_parts=("📁 ${dir}")
[ -n "$git_part" ]   && line1_parts+=("$git_part")
[ -n "$model_part" ] && line1_parts+=("$model_part")

line1=""
for p in "${line1_parts[@]}"; do
    line1="${line1:+${line1} | }${p}"
done

# Line 2: usage (context bar, rate limits)
line2_parts=()
[ -n "$ctx_part" ]   && line2_parts+=("$ctx_part")
[ -n "$limit_part" ] && line2_parts+=("$limit_part")

line2=""
for p in "${line2_parts[@]}"; do
    line2="${line2:+${line2} | }${p}"
done

printf "%s\n" "$line1"
[ -n "$line2" ] && printf "%s\n" "$line2"
