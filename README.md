# claude-statusline

A custom status line for [Claude Code](https://claude.ai/code) showing:

```
📁 my-project | 🌿 main | 🧠 45% [=========>          ] | 🤖 Sonnet | 5h: 12% | 7d: 33%
```

| Segment | Description |
|---|---|
| 📁 | Current working directory name |
| 🌿 | Git branch (shown only inside a git repo) |
| 🧠 | Context window usage with a visual progress bar |
| 🤖 | Active model name |
| 5h / 7d | Rate limit usage (Claude.ai subscription plans only, appears after first API response) |

## Requirements

- `bash`
- `jq`

## Install via plugin (recommended)

Run these three slash commands inside Claude Code:

```
/plugin marketplace add tranvansanghust/claude-statusline
/plugin install claude-statusline
/reload-plugins
/claude-statusline:setup
```

That's it. The statusline will appear on your next prompt.

## Manual install

1. Download `bin/statusline.sh` and copy it to `~/.claude/`:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/tranvansanghust/claude-statusline/main/bin/statusline.sh \
     -o ~/.claude/statusline-command.sh
   chmod +x ~/.claude/statusline-command.sh
   ```

2. Add to `~/.claude/settings.json` (create the file if it doesn't exist):
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

## Customizing

The statusline is a plain bash script at `~/.claude/statusline-command.sh`. Edit it directly to change the format, icons, or which segments are shown.

The script reads a JSON object on stdin that Claude Code provides on every prompt. Available fields:

| Field | Description |
|---|---|
| `.workspace.current_dir` | Absolute path of the current workspace |
| `.model.display_name` | Active model name |
| `.context_window.used_percentage` | Context usage as a float (0–100) |
| `.rate_limits.five_hour.used_percentage` | 5-hour rate limit usage |
| `.rate_limits.seven_day.used_percentage` | 7-day rate limit usage |

## Uninstall

```bash
# Remove the script and terminal-width file
rm ~/.claude/statusline-command.sh ~/.claude/terminal-width

# Remove statusLine from settings.json
jq 'del(.statusLine)' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json

# Remove the shell wrapper from ~/.zshrc (or ~/.bashrc)
# Delete the 4 lines starting with "# claude-statusline"
```

Then in Claude Code:
```
/plugin uninstall claude-statusline
```

## License

MIT
