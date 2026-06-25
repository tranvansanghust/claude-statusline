---
name: setup
description: Install the claude-statusline script into ~/.claude and configure it as the active statusLine in settings.json
---

# Setup claude-statusline

Install the bundled statusline script for the user and wire it up in their Claude Code settings.

## Steps

1. Locate the plugin's `bin/statusline.sh` (it lives alongside this skill, in the plugin root's `bin/` directory). Copy it to `~/.claude/statusline-command.sh` and make it executable (`chmod +x`).

2. Check whether `jq` is installed (`which jq`). If missing, tell the user to install it (e.g. `brew install jq` on macOS, `apt install jq` on Debian/Ubuntu) since the script depends on it.

3. Update `~/.claude/settings.json`:
   - If the file doesn't exist, create it with:
     ```json
     {
       "statusLine": {
         "type": "command",
         "command": "bash ~/.claude/statusline-command.sh"
       }
     }
     ```
   - If it exists, merge in the `statusLine` key above without disturbing other existing settings (use `jq` to merge, write to a temp file, then move it into place). Back up the original file first as `settings.json.bak`.

4. Tell the user the statusline is installed and will show on their next prompt. Mention they can customize the format by editing `~/.claude/statusline-command.sh`.

## Notes

- Never overwrite unrelated keys in `settings.json`.
- If a `statusLine` config already exists, ask the user before replacing it.
