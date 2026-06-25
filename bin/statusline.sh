#!/usr/bin/env bash
# Claude Code status line
# Format: 📁 folder | 🌿 branch | 🧠 ctx% [bar] | 🤖 model | 5h: x% | 7d: y%

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

# Assemble — each segment on its own line if needed; terminal wraps naturally
parts=("📁 ${dir}")
[ -n "$git_part" ]   && parts+=("$git_part")
[ -n "$ctx_part" ]   && parts+=("$ctx_part")
[ -n "$model_part" ] && parts+=("$model_part")
[ -n "$limit_part" ] && parts+=("$limit_part")

result=""
for p in "${parts[@]}"; do
    result="${result:+${result} | }${p}"
done

printf "%s\n" "$result"
