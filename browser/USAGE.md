# EmacsClient Chrome Extension Usage Guide

## Installation

1. Build the extension:
   ```bash
   cd browser
   bun install
   bun run build
   ```

2. Load the extension in Chrome:
   - Open Chrome and go to `chrome://extensions/`
   - Enable "Developer mode" (toggle in the top right)
   - Click "Load unpacked"
   - Select the `browser/.output/chrome-mv3` directory

## Configuration

1. Open extension options from Chrome's extension page
2. Add actions by entering:
   - **Name** (e.g., `Capture Note`)
   - **Elisp Code** (e.g., `(org-capture)`)
3. Save changes

## Using the Extension

Once you've configured actions:

1. Press the extension shortcut (default: `Ctrl+Shift+E` on Windows/Linux, `Command+Shift+E` on macOS), or click the extension icon
2. The popup command palette opens
3. Type to filter actions, use arrow keys to navigate, and press Enter to execute
4. The extension invokes: `emacs://eval?expr={your-elisp-code}`

## Development

For development with hot-reload:
```bash
bun run dev
```

## Notes

- The extension uses one Chrome command (`_execute_action`) to open the popup
- The extension requests `activeTab` + `scripting` so it can dispatch `emacs://` from the current tab context when you run an action
- The extension stores your configuration in Chrome's local storage
- Make sure your Emacs is configured to handle the `emacs://` URL protocol
