---
name: setup
description: Install the claude-statusline script into ~/.claude, configure it as the active statusLine in settings.json, and add a shell wrapper to capture terminal width
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

4. Add a shell wrapper to capture terminal width. The statusline script reads `~/.claude/terminal-width` to size the progress bar correctly — Claude Code runs the statusline as a subprocess with no TTY access, so `tput cols` returns the wrong value. The wrapper writes `$COLUMNS` to that file before launching Claude Code.

   Detect the user's shell and append to the appropriate rc file:
   - zsh → `~/.zshrc`
   - bash → `~/.bashrc`
   - fish → `~/.config/fish/config.fish` (use fish function syntax)

   For zsh/bash, append **only if the marker `# claude-statusline` is not already present**:
   ```sh
   # claude-statusline
   function claude() {
       echo $COLUMNS > ~/.claude/terminal-width
       command claude "$@"
   }
   ```

   For fish:
   ```fish
   # claude-statusline
   function claude
       echo $COLUMNS > ~/.claude/terminal-width
       command claude $argv
   end
   ```

   After appending, tell the user to run `source ~/.zshrc` (or equivalent) or restart their terminal, then relaunch Claude Code for the responsive bar to take effect.

5. Tell the user the statusline is installed. Mention they can customize the format by editing `~/.claude/statusline-command.sh`.

## Notes

- Never overwrite unrelated keys in `settings.json`.
- If a `statusLine` config already exists, ask the user before replacing it.
- Never append the shell wrapper more than once (check for the `# claude-statusline` marker first).
