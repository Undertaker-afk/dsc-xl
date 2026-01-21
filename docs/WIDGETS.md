# Lite XL Widgets Library

The lite-xl-widgets library is pre-integrated in this distribution and provides a comprehensive set of GUI components for plugin developers.

## Location

The library is located at: `data/libraries/widget/`

This follows the standard Lite XL library path convention and allows plugins to require it using:

```lua
local Widget = require "libraries.widget"
local Button = require "libraries.widget.button"
-- etc.
```

## Source

**Original Repository:** https://github.com/lite-xl/lite-xl-widgets

The widgets library is maintained by the Lite XL community and provides a standardized way to create interactive UI elements.

## Included Components

The library includes the following widget components:

### Basic Components
- **Widget** (`init.lua`) - Base widget class
- **Button** (`button.lua`) - Clickable button
- **CheckBox** (`checkbox.lua`) - Toggle checkbox
- **Label** (`label.lua`) - Text label
- **Line** (`line.lua`) - Horizontal/vertical line separator
- **ProgressBar** (`progressbar.lua`) - Progress indicator
- **Toggle** (`toggle.lua`) - Toggle switch

### Input Components
- **TextBox** (`textbox.lua`) - Text input field
- **NumberBox** (`numberbox.lua`) - Numeric input field
- **SelectBox** (`selectbox.lua`) - Dropdown selection

### Advanced Components
- **ColorPicker** (`colorpicker.lua`) - Color selection widget
- **ColorPickerDialog** (`colorpickerdialog.lua`) - Color picker dialog
- **FilePicker** (`filepicker.lua`) - File selection dialog
- **FontDialog** (`fontdialog.lua`) - Font selection dialog
- **FontsList** (`fontslist.lua`) - Font list display
- **InputDialog** (`inputdialog.lua`) - Text input dialog
- **KeybindDialog** (`keybinddialog.lua`) - Keybinding editor
- **MessageBox** (`messagebox.lua`) - Message/confirmation dialog

### Container Components
- **Dialog** (`dialog.lua`) - Base dialog window
- **FoldingBook** (`foldingbook.lua`) - Collapsible sections
- **ItemsList** (`itemslist.lua`) - List of items
- **ListBox** (`listbox.lua`) - Scrollable list
- **NoteBook** (`notebook.lua`) - Tabbed interface
- **TreeList** (`treelist.lua`) - Hierarchical tree view

### Utility Components
- **ScrollBar** (`scrollbar.lua`) - Custom scrollbar
- **SearchReplaceList** (`searchreplacelist.lua`) - Search/replace interface

## Features

### Core Capabilities
- **Dragging** - Movable widgets
- **Floating Views** - Modal dialogs and popups
- **Hover Events** - Mouse-over detection
- **Click Events** - Mouse click handling
- **Tooltips** - Status view integration
- **Performance** - Automatic detection of widgets that don't need updates
- **Relative Positioning** - Child widget coordinates relative to parent

### View System Integration
All widgets leverage Lite XL's View system, ensuring:
- Consistent rendering
- Proper event handling
- Integration with the editor's drawing pipeline
- Efficient updates and redraws

## Usage Example

Here's a simple example of creating a button:

```lua
local Button = require "libraries.widget.button"

local my_button = Button(nil, "Click Me")
my_button:set_position(100, 100)
my_button:set_size(100, 30)

my_button.on_click = function(button, mx, my)
    core.log("Button clicked!")
end
```

## Font Resources

The library includes custom fonts in the `fonts/` directory:
- Material Design icons font
- Used for rendering icons in various widgets

## License

The lite-xl-widgets library is licensed under the MIT License.

See `data/libraries/widget/LICENSE` for full license text.

## Contributing

For issues, contributions, or updates to the widgets library, please visit:
https://github.com/lite-xl/lite-xl-widgets

## Integration Notes

This library is pre-integrated in this distribution of Lite XL to ensure:
1. The settings plugin works out of the box
2. Plugin developers have immediate access to GUI components
3. Consistent UI experience across plugins
4. No manual installation steps required for end users

## Version Information

This integration includes the latest stable version of lite-xl-widgets as of the integration date.

To check for updates or view the changelog, visit the upstream repository.
