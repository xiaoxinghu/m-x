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

1. Click the EmacsClient extension icon in Chrome's toolbar
2. The popup will show the configuration interface

### Adding an Action

1. Enter a **Name** for your action (e.g., "Capture Note")
2. Enter the **Elisp Code** to execute (e.g., `(org-capture)`)
3. Click the **Keybinding** recorder button
4. Press your desired key combination (e.g., Ctrl+Shift+C)
5. Click "Add Action"

### Editing/Deleting Actions

- Click "Edit" to modify an existing action
- Click "Delete" to remove an action

## Using the Extension

Once you've configured actions with keybindings:

1. Navigate to any webpage
2. Press your configured keybinding
3. The extension will invoke the Emacs URL: `emacs://eval?expr={your-elisp-code}`
4. Your Emacs instance (with the URL handler configured) will execute the elisp code

## Development

For development with hot-reload:
```bash
bun run dev
```

## Notes

- The extension requires `<all_urls>` permission to listen for keybindings on all pages
- Keybindings must include at least one modifier key (Ctrl, Alt, or Meta/Command)
- The extension stores your configuration in Chrome's local storage
- Make sure your Emacs is configured to handle the `emacs://` URL protocol
