#!/usr/bin/env bash
# Claude Code status line
# Format: 📁 folder | 🌿 branch | 🧠 ctx% [bar] | 🤖 model | 5h: x% | 7d: y%

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')

# Git branch (skip optional locks to avoid blocking)
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# Context window
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limits (Claude.ai subscription — present only after first API response)
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Terminal width (fallback to 80)
term_width=$(tput cols 2>/dev/null || echo 80)

# Build fixed parts (no bar yet)
used_int=""
git_part=""
model_part=""
limit_part=""

[ -n "$branch" ] && git_part="🌿 ${branch}"
[ -n "$model" ]  && model_part="🤖 ${model}"

if [ -n "$five_hour" ]; then
    five_int=$(printf "%.0f" "$five_hour")
    limit_part="5h: ${five_int}%"
fi
if [ -n "$seven_day" ]; then
    seven_int=$(printf "%.0f" "$seven_day")
    limit_part="${limit_part:+${limit_part} | }7d: ${seven_int}%"
fi

# Estimate display width of all fixed text (emojis count as 2 cols each)
# Build a probe string replacing each emoji with "XX" to get accurate col count
probe="📁 ${dir}"
emoji_count=1
[ -n "$git_part" ] && { probe="${probe} | ${git_part}"; emoji_count=$((emoji_count + 1)); }
if [ -n "$used" ]; then
    used_int=$(printf "%.0f" "$used")
    probe="${probe} | 🧠 ${used_int}% []"  # [] = placeholder for bar
    emoji_count=$((emoji_count + 1))
fi
[ -n "$model_part" ] && { probe="${probe} | ${model_part}"; emoji_count=$((emoji_count + 1)); }
[ -n "$limit_part" ] && probe="${probe} | ${limit_part}"

# ${#probe} counts unicode chars; add emoji_count for extra column each emoji occupies
fixed_len=$(( ${#probe} + emoji_count ))

# Bar width fills remaining space (min 4, max 40)
bar_width=$(( term_width - fixed_len ))
[ "$bar_width" -lt 4 ]  && bar_width=4
[ "$bar_width" -gt 40 ] && bar_width=40

# Build progress bar
ctx_part=""
if [ -n "$used" ]; then
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

# Assemble
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
