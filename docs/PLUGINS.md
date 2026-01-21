# New Plugins Integration

This document describes the newly integrated plugins in Lite XL.

## Integrated Plugins

### 1. Autosave (`autosave.lua`)
**Source:** https://github.com/lite-xl/lite-xl-plugins

Automatically saves documents after a period of inactivity.

**Features:**
- Configurable timeout (default: 1 second)
- Can be enabled/disabled via settings
- Excludes user config files from autosave

**Commands:**
- No direct commands (automatic behavior)

**Configuration:**
```lua
config.plugins.autosave.enabled = true
config.plugins.autosave.timeout = 1  -- seconds
```

---

### 2. Autowrap (`autowrap.lua`)
**Source:** https://github.com/lite-xl/lite-xl-plugins

Automatically wraps text when reaching the line limit.

**Features:**
- Wraps text automatically for markdown and text files
- Configurable file patterns
- Can be toggled on/off

**Commands:**
- `auto-wrap:toggle` - Toggle auto-wrap functionality

**Configuration:**
```lua
config.plugins.autowrap.enabled = false
config.plugins.autowrap.files = { "%.md$", "%.txt$" }
```

---

### 3. Code Plus (`code_plus.lua`)
**Source:** https://github.com/chqs-git/code-plus

Enhanced code editing with highlighted comments and autocomplete.

**Features:**
- Highlights `@todo(...)` and `@fixme(...)` comments
- Auto-completes brackets, parentheses, and quotes
- Customizable highlight colors

**Commands:**
- `code_plus:complete_brackets` - Complete square brackets
- `code_plus:complete_curly_brackets` - Complete curly brackets
- `code_plus:complete_parantheses` - Complete parentheses
- `code_plus:complete_quotation_marks` - Complete double quotes
- `code_plus:complete_single_quotation_marks` - Complete single quotes

**Keybindings:**
- `AltGr+8` / `Ctrl+Alt+8` - Complete brackets
- `AltGr+7` / `Ctrl+Alt+7` - Complete curly brackets
- `Shift+8` - Complete parentheses
- `Shift+2` - Complete quotes

**Configuration:**
```lua
config.plugins.code_plus.enabled = true
config.plugins.code_plus.todo = "#5592CF"
config.plugins.code_plus.fixme = "#EF6385"
config.plugins.code_plus.autocomplete_enabled = true
```

---

### 4. Console (`console.lua`)
**Source:** https://github.com/lite-xl/console

Integrated terminal console for running commands.

**Features:**
- Toggle-able console view
- Execute shell commands from within the editor
- Click on file paths in output to open them
- Command history
- Configurable size and behavior

**Commands:**
- `console:toggle` - Toggle console visibility
- `console:run` - Run a console command
- `console:open-console` - Open console in a new view
- `console:reset-output` - Clear console output

**Keybindings:**
- `Ctrl+.` - Toggle console
- `Ctrl+Shift+.` - Run console command

**Configuration:**
```lua
config.plugins.console.size = 250 * SCALE
config.plugins.console.max_lines = 200
config.plugins.console.autoscroll = true
```

---

### 5. Line Numbers (`linenumbers.lua`)
**Source:** https://github.com/lite-xl/lite-xl-plugins

Enhanced line number display with relative and hybrid modes.

**Features:**
- Show/hide line numbers
- Relative line numbers (distance from current line)
- Hybrid mode (absolute for current line, relative for others)

**Commands:**
- `line-numbers:toggle` - Toggle line numbers
- `line-numbers:enable` - Show line numbers
- `line-numbers:disable` - Hide line numbers
- `relative-line-numbers:toggle` - Toggle relative mode
- `hybrid-line-numbers:toggle` - Toggle hybrid mode

**Configuration:**
```lua
config.plugins.linenumbers.show = true
config.plugins.linenumbers.relative = false
config.plugins.linenumbers.hybrid = false
```

---

### 6. LSP C (`lsp_c.lua`)
**Source:** https://github.com/lite-xl/lite-xl-lsp-servers

Language Server Protocol integration for C/C++.

**Features:**
- Integrates with clangd language server
- Requires lite-xl-lsp plugin to be installed
- Provides code completion, diagnostics, and more for C/C++ files

**Note:** This plugin requires the `lite-xl-lsp` plugin to be installed separately.

---

### 7. Minimap (`minimap.lua`)
**Source:** https://github.com/lite-xl/lite-xl-plugins

Displays a miniature overview of the current document.

**Features:**
- Syntax highlighted minimap
- Configurable size and scale
- Shows current viewport location
- Click to navigate
- Can be toggled per-view or globally

**Commands:**
- `minimap:toggle-visibility` - Toggle minimap globally
- `minimap:toggle-visibility-for-current-view` - Toggle for current view only
- `minimap:toggle-syntax-highlighting` - Toggle syntax highlighting in minimap

**Configuration:**
```lua
config.plugins.minimap.enabled = true
config.plugins.minimap.width = 100
config.plugins.minimap.instant_scroll = false
config.plugins.minimap.syntax_highlight = true
config.plugins.minimap.scale = 1
```

---

### 8. Settings (`settings.lua`)
**Source:** https://github.com/lite-xl/lite-xl-plugins

Graphical settings interface for Lite XL.

**Features:**
- Visual configuration interface
- Organize settings by categories
- Support for various setting types (toggle, number, color, etc.)
- Plugin settings integration
- Font picker
- Keybinding editor

**Dependencies:** Uses the integrated `lite-xl-widgets` library (included in `data/libraries/widget/`).

---

### 9. Git Control (`gitcontrol.lua`)
**Custom Integration** - Inspired by VS Code's Source Control

A comprehensive git integration with a visual interface similar to VS Code.

**Features:**
- Visual git status display
- Separate sections for staged, unstaged, and untracked files
- File count badges
- Collapsible sections
- File operations via context menu
- Auto-refresh with configurable interval
- Branch display
- Integration with project directory

**Commands:**
- `git-control:toggle` - Toggle git control view
- `git-control:refresh` - Manually refresh git status
- `git-control:stage-all` - Stage all changes
- `git-control:unstage-all` - Unstage all changes
- `git-control:commit` - Commit staged changes
- `git-control:pull` - Pull from remote
- `git-control:push` - Push to remote

**Keybindings:**
- `Ctrl+Shift+G` - Toggle git control view
- `Ctrl+Shift+R` - Refresh git status

**File Operations (via context menu):**
- Stage/unstage individual files
- Discard changes
- Open files

**Configuration:**
```lua
config.plugins.gitcontrol.auto_refresh = true
config.plugins.gitcontrol.refresh_interval = 2  -- seconds
config.plugins.gitcontrol.size = 250 * SCALE
```

---

## Installation Notes

All plugins are now directly integrated into the `data/plugins` directory and will be loaded automatically when Lite XL starts.

### Integrated Libraries

The following libraries are pre-integrated in the `data/libraries/` directory:

1. **lite-xl-widgets** (`data/libraries/widget/`)
   - Provides GUI components for the settings plugin
   - Includes 30+ widget components (buttons, dialogs, color pickers, etc.)
   - No manual installation required

### External Dependencies

Some plugins have external dependencies that need to be installed separately:

1. **LSP C Plugin** requires:
   - `lite-xl-lsp` plugin (separate installation)
   - clangd language server (system installation)

### Usage Tips

1. **Settings Plugin**: Use this to configure all other plugins through a graphical interface
2. **Console Plugin**: Great for running build commands, tests, and scripts without leaving the editor
3. **Git Control**: Similar to VS Code's source control - use Ctrl+Shift+G to open
4. **Minimap**: Provides a bird's-eye view of your code, useful for navigation in large files
5. **Autosave**: Helps prevent data loss - configure timeout to your preference

---

## Troubleshooting

### Plugin Not Loading

If a plugin doesn't load:
1. Check the console for error messages
2. Ensure all dependencies are installed
3. Verify the plugin file is in `data/plugins/` directory
4. Check that the plugin is compatible with your Lite XL version (mod-version)

### Git Control Not Working

If git control shows "Git not available":
1. Ensure git is installed and available in your PATH
2. Check that your project is a git repository
3. Verify you have permissions to access the git repository

### Settings Plugin Not Loading

The settings plugin should work out of the box as the `lite-xl-widgets` library is pre-integrated.
If it still fails to load:
1. Verify `data/libraries/widget/` directory exists and contains the widget files
2. Check the console for error messages
3. Restart Lite XL

---

## Contributing

These plugins are maintained by their respective authors. For issues or contributions:

- Core plugins: https://github.com/lite-xl/lite-xl-plugins
- Code Plus: https://github.com/chqs-git/code-plus
- Console: https://github.com/lite-xl/console
- LSP Servers: https://github.com/lite-xl/lite-xl-lsp-servers
- Git Control: Custom integration for this repository
