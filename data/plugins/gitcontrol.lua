-- mod-version:4
-- Git Source Control Integration Plugin for Lite XL
-- Provides a VS Code-like source control menu

local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local keymap = require "core.keymap"
local style = require "core.style"
local View = require "core.view"
local ContextMenu = require "core.contextmenu"

config.plugins.gitcontrol = common.merge({
  size = 250 * SCALE,
  visible = false,
  auto_refresh = true,
  refresh_interval = 2, -- seconds
  config_spec = {
    name = "Git Control",
    {
      label = "Auto Refresh",
      description = "Automatically refresh git status.",
      path = "auto_refresh",
      type = "toggle",
      default = true
    },
    {
      label = "Refresh Interval",
      description = "Time in seconds between automatic refreshes.",
      path = "refresh_interval",
      type = "number",
      default = 2,
      min = 1,
      max = 30
    }
  }
}, config.plugins.gitcontrol)

local GitControlView = View:extend()

function GitControlView:__tostring() return "GitControlView" end

function GitControlView:new()
  GitControlView.super.new(self)
  self.scrollable = true
  self.visible = config.plugins.gitcontrol.visible
  self.target_size = config.plugins.gitcontrol.size
  self.init_size = true
  
  self.git_status = {
    branch = "unknown",
    staged = {},
    unstaged = {},
    untracked = {}
  }
  
  self.last_refresh = 0
  self.hovered_idx = nil
  self.expanded = {
    staged = true,
    unstaged = true,
    untracked = true
  }
  
  self:refresh_git_status()
end

function GitControlView:set_target_size(axis, value)
  if axis == "x" then
    self.target_size = value
    return true
  end
end

function GitControlView:get_name()
  return "Git Control"
end

function GitControlView:refresh_git_status()
  local project_dir = core.project_dir
  if not project_dir then return end
  
  -- Check if git is available and we're in a git repo
  local has_git = os.execute("git --version > /dev/null 2>&1") == true or 
                  os.execute("git --version > nul 2>&1") == 0
  
  if not has_git then
    self.git_status.branch = "Git not available"
    return
  end
  
  -- Get current branch
  local branch_handle = io.popen("cd " .. project_dir .. " && git branch --show-current 2>&1")
  if branch_handle then
    local branch = branch_handle:read("*l")
    branch_handle:close()
    if branch and branch ~= "" and not branch:match("^fatal:") then
      self.git_status.branch = branch
    else
      self.git_status.branch = "Not a git repository"
      return
    end
  end
  
  -- Get git status
  local status_handle = io.popen("cd " .. project_dir .. " && git status --porcelain 2>&1")
  if status_handle then
    self.git_status.staged = {}
    self.git_status.unstaged = {}
    self.git_status.untracked = {}
    
    for line in status_handle:lines() do
      local status = line:sub(1, 2)
      local file = line:sub(4)
      
      if status:match("^%?%?") then
        table.insert(self.git_status.untracked, file)
      elseif status:match("^[MADRC]") then
        table.insert(self.git_status.staged, file)
      elseif status:match("^.[MD]") or status:match("^ [MADRC]") then
        table.insert(self.git_status.unstaged, file)
      end
    end
    status_handle:close()
  end
  
  self.last_refresh = system.get_time()
end

function GitControlView:get_scrollable_size()
  local total_lines = 3 -- header + branch + separator
  
  if self.expanded.staged then
    total_lines = total_lines + #self.git_status.staged + 1
  else
    total_lines = total_lines + 1
  end
  
  if self.expanded.unstaged then
    total_lines = total_lines + #self.git_status.unstaged + 1
  else
    total_lines = total_lines + 1
  end
  
  if self.expanded.untracked then
    total_lines = total_lines + #self.git_status.untracked + 1
  else
    total_lines = total_lines + 1
  end
  
  return total_lines * self:get_item_height() + style.padding.y * 2
end

function GitControlView:get_item_height()
  return style.font:get_height() + style.padding.y
end

function GitControlView:each_item()
  return coroutine.wrap(function()
    local x, y = self:get_content_offset()
    local h = self:get_item_height()
    
    -- Header
    coroutine.yield("header", "SOURCE CONTROL", x, y, h)
    y = y + h
    
    -- Branch
    coroutine.yield("branch", "Branch: " .. self.git_status.branch, x, y, h)
    y = y + h
    
    -- Separator
    y = y + h / 2
    
    -- Staged changes
    local staged_count = #self.git_status.staged
    local staged_label = string.format("▸ Staged Changes (%d)", staged_count)
    if self.expanded.staged then
      staged_label = string.format("▾ Staged Changes (%d)", staged_count)
    end
    coroutine.yield("section", staged_label, x, y, h, "staged")
    y = y + h
    
    if self.expanded.staged then
      for i, file in ipairs(self.git_status.staged) do
        coroutine.yield("file", file, x + style.padding.x * 2, y, h, "staged", i)
        y = y + h
      end
    end
    
    -- Unstaged changes
    local unstaged_count = #self.git_status.unstaged
    local unstaged_label = string.format("▸ Changes (%d)", unstaged_count)
    if self.expanded.unstaged then
      unstaged_label = string.format("▾ Changes (%d)", unstaged_count)
    end
    coroutine.yield("section", unstaged_label, x, y, h, "unstaged")
    y = y + h
    
    if self.expanded.unstaged then
      for i, file in ipairs(self.git_status.unstaged) do
        coroutine.yield("file", file, x + style.padding.x * 2, y, h, "unstaged", i)
        y = y + h
      end
    end
    
    -- Untracked files
    local untracked_count = #self.git_status.untracked
    local untracked_label = string.format("▸ Untracked Files (%d)", untracked_count)
    if self.expanded.untracked then
      untracked_label = string.format("▾ Untracked Files (%d)", untracked_count)
    end
    coroutine.yield("section", untracked_label, x, y, h, "untracked")
    y = y + h
    
    if self.expanded.untracked then
      for i, file in ipairs(self.git_status.untracked) do
        coroutine.yield("file", file, x + style.padding.x * 2, y, h, "untracked", i)
        y = y + h
      end
    end
  end)
end

function GitControlView:on_mouse_moved(mx, my, ...)
  GitControlView.super.on_mouse_moved(self, mx, my, ...)
  self.hovered_idx = nil
  
  for item_type, text, x, y, h, section, idx in self:each_item() do
    if mx >= x and my >= y and mx < x + self.size.x and my < y + h then
      if item_type == "file" then
        self.hovered_idx = { type = section, idx = idx }
      elseif item_type == "section" then
        self.hovered_idx = { type = "section", section = section }
      end
      break
    end
  end
end

function GitControlView:on_mouse_pressed(button, x, y, clicks)
  if GitControlView.super.on_mouse_pressed(self, button, x, y, clicks) then
    return true
  end
  
  if not self.hovered_idx then return false end
  
  if self.hovered_idx.type == "section" then
    -- Toggle section expansion
    local section = self.hovered_idx.section
    self.expanded[section] = not self.expanded[section]
    return true
  end
  
  local section = self.hovered_idx.type
  local idx = self.hovered_idx.idx
  local files = self.git_status[section]
  local file = files[idx]
  
  if button == "left" and clicks == 1 then
    -- Open file
    local filename = core.project_dir .. PATHSEP .. file
    core.root_view:open_doc(core.open_doc(filename))
    return true
  elseif button == "right" then
    -- Show context menu
    self:show_context_menu(section, file, x, y)
    return true
  end
  
  return false
end

function GitControlView:show_context_menu(section, file, x, y)
  local menu = ContextMenu()
  
  if section == "unstaged" then
    menu:register(nil, {
      { text = "Stage File", command = function()
          self:stage_file(file)
        end
      },
      { text = "Discard Changes", command = function()
          self:discard_changes(file)
        end
      }
    })
  elseif section == "staged" then
    menu:register(nil, {
      { text = "Unstage File", command = function()
          self:unstage_file(file)
        end
      }
    })
  elseif section == "untracked" then
    menu:register(nil, {
      { text = "Stage File", command = function()
          self:stage_file(file)
        end
      }
    })
  end
  
  menu:show(x, y)
end

function GitControlView:stage_file(file)
  local cmd = string.format("cd %s && git add \"%s\"", core.project_dir, file)
  os.execute(cmd)
  core.log("Staged: %s", file)
  self:refresh_git_status()
end

function GitControlView:unstage_file(file)
  local cmd = string.format("cd %s && git reset HEAD \"%s\"", core.project_dir, file)
  os.execute(cmd)
  core.log("Unstaged: %s", file)
  self:refresh_git_status()
end

function GitControlView:discard_changes(file)
  local cmd = string.format("cd %s && git checkout -- \"%s\"", core.project_dir, file)
  os.execute(cmd)
  core.log("Discarded changes: %s", file)
  self:refresh_git_status()
end

function GitControlView:commit_staged()
  core.command_view:enter("Commit Message", {
    submit = function(msg)
      if msg and msg ~= "" then
        local cmd = string.format("cd %s && git commit -m \"%s\"", core.project_dir, msg)
        local result = os.execute(cmd)
        if result then
          core.log("Committed changes")
          self:refresh_git_status()
        else
          core.error("Failed to commit changes")
        end
      end
    end
  })
end

function GitControlView:update(...)
  if self.visible and self.init_size then
    self.init_size = false
    self.size.x = self.target_size
  end
  
  local dest = self.visible and self.target_size or 0
  self:move_towards(self.size, "x", dest, nil, "gitcontrol")
  
  -- Auto refresh
  if config.plugins.gitcontrol.auto_refresh then
    local time = system.get_time()
    if time - self.last_refresh >= config.plugins.gitcontrol.refresh_interval then
      self:refresh_git_status()
    end
  end
  
  GitControlView.super.update(self, ...)
end

function GitControlView:draw()
  self:draw_background(style.background2)
  
  for item_type, text, x, y, h, section, idx in self:each_item() do
    local color = style.text
    local is_hovered = false
    
    if self.hovered_idx then
      if item_type == "file" and self.hovered_idx.type == section and self.hovered_idx.idx == idx then
        is_hovered = true
        renderer.draw_rect(x, y, self.size.x, h, style.line_highlight)
        color = style.accent
      elseif item_type == "section" and self.hovered_idx.type == "section" and self.hovered_idx.section == section then
        is_hovered = true
        renderer.draw_rect(x, y, self.size.x, h, style.line_highlight)
        color = style.accent
      end
    end
    
    if item_type == "header" then
      color = style.accent
      common.draw_text(style.font, color, text, "left", x + style.padding.x, y, self.size.x, h)
    elseif item_type == "branch" then
      color = style.dim
      common.draw_text(style.font, color, text, "left", x + style.padding.x, y, self.size.x, h)
    elseif item_type == "section" then
      common.draw_text(style.font, color, text, "left", x + style.padding.x, y, self.size.x, h)
    elseif item_type == "file" then
      -- Draw status icon
      local icon = "M"
      if section == "untracked" then
        icon = "U"
      elseif section == "staged" then
        icon = "✓"
      end
      
      common.draw_text(style.code_font, style.accent, icon, "left", x, y, style.padding.x * 2, h)
      common.draw_text(style.font, color, text, "left", x + style.padding.x, y, self.size.x, h)
    end
  end
  
  self:draw_scrollbar(self)
end

-- Create the view
local view = nil

local function get_git_control_view()
  if not view then
    view = GitControlView()
    local node = core.root_view:get_active_node_default()
    local treeview_node = core.root_view.root_node:get_node_for_view(core.treeview)
    if treeview_node then
      node = treeview_node
    end
    node:split("right", view, {x = true}, true)
  end
  return view
end

-- Commands
command.add(nil, {
  ["git-control:toggle"] = function()
    get_git_control_view().visible = not get_git_control_view().visible
  end,
  
  ["git-control:refresh"] = function()
    get_git_control_view():refresh_git_status()
    core.log("Git status refreshed")
  end,
  
  ["git-control:stage-all"] = function()
    local cmd = string.format("cd %s && git add .", core.project_dir)
    os.execute(cmd)
    core.log("Staged all changes")
    get_git_control_view():refresh_git_status()
  end,
  
  ["git-control:unstage-all"] = function()
    local cmd = string.format("cd %s && git reset HEAD .", core.project_dir)
    os.execute(cmd)
    core.log("Unstaged all changes")
    get_git_control_view():refresh_git_status()
  end,
  
  ["git-control:commit"] = function()
    get_git_control_view():commit_staged()
  end,
  
  ["git-control:pull"] = function()
    local cmd = string.format("cd %s && git pull", core.project_dir)
    local result = os.execute(cmd)
    if result then
      core.log("Pulled from remote")
      get_git_control_view():refresh_git_status()
    else
      core.error("Failed to pull from remote")
    end
  end,
  
  ["git-control:push"] = function()
    local cmd = string.format("cd %s && git push", core.project_dir)
    local result = os.execute(cmd)
    if result then
      core.log("Pushed to remote")
      get_git_control_view():refresh_git_status()
    else
      core.error("Failed to push to remote")
    end
  end,
})

-- Keybindings
keymap.add {
  ["ctrl+shift+g"] = "git-control:toggle",
  ["ctrl+shift+r"] = "git-control:refresh"
}

return {
  view = view,
  get_view = get_git_control_view
}
