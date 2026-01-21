-- mod-version:4
-- AI Copilot Plugin for Lite XL
-- Provides AI-powered coding assistance with multiple modes

local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"
local common = require "core.common"
local config = require "core.config"
local style = require "core.style"
local View = require "core.view"
local DocView = require "core.docview"
local Doc = require "core.doc"

-- JSON encoder/decoder (simple implementation)
local json = {}

function json.encode(val)
  local type_val = type(val)
  
  if type_val == "nil" then
    return "null"
  elseif type_val == "boolean" then
    return tostring(val)
  elseif type_val == "number" then
    return tostring(val)
  elseif type_val == "string" then
    return '"' .. val:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
  elseif type_val == "table" then
    local is_array = #val > 0
    local parts = {}
    
    if is_array then
      for i = 1, #val do
        table.insert(parts, json.encode(val[i]))
      end
      return "[" .. table.concat(parts, ",") .. "]"
    else
      for k, v in pairs(val) do
        table.insert(parts, json.encode(tostring(k)) .. ":" .. json.encode(v))
      end
      return "{" .. table.concat(parts, ",") .. "}"
    end
  end
  
  return "null"
end

function json.decode(str)
  local pos = 1
  
  local function skip_whitespace()
    while pos <= #str and str:sub(pos, pos):match("%s") do
      pos = pos + 1
    end
  end
  
  local function parse_value()
    skip_whitespace()
    local char = str:sub(pos, pos)
    
    if char == '"' then
      -- Parse string
      pos = pos + 1
      local start = pos
      while pos <= #str and str:sub(pos, pos) ~= '"' do
        if str:sub(pos, pos) == '\\' then pos = pos + 1 end
        pos = pos + 1
      end
      local result = str:sub(start, pos - 1)
      pos = pos + 1
      return result:gsub('\\n', '\n'):gsub('\\r', '\r'):gsub('\\t', '\t'):gsub('\\"', '"'):gsub('\\\\', '\\')
    elseif char == '{' then
      -- Parse object
      pos = pos + 1
      local obj = {}
      skip_whitespace()
      if str:sub(pos, pos) == '}' then
        pos = pos + 1
        return obj
      end
      while true do
        skip_whitespace()
        local key = parse_value()
        skip_whitespace()
        if str:sub(pos, pos) ~= ':' then break end
        pos = pos + 1
        local value = parse_value()
        obj[key] = value
        skip_whitespace()
        if str:sub(pos, pos) == ',' then
          pos = pos + 1
        elseif str:sub(pos, pos) == '}' then
          pos = pos + 1
          break
        end
      end
      return obj
    elseif char == '[' then
      -- Parse array
      pos = pos + 1
      local arr = {}
      skip_whitespace()
      if str:sub(pos, pos) == ']' then
        pos = pos + 1
        return arr
      end
      while true do
        table.insert(arr, parse_value())
        skip_whitespace()
        if str:sub(pos, pos) == ',' then
          pos = pos + 1
        elseif str:sub(pos, pos) == ']' then
          pos = pos + 1
          break
        end
      end
      return arr
    elseif str:sub(pos, pos + 3) == "true" then
      pos = pos + 4
      return true
    elseif str:sub(pos, pos + 4) == "false" then
      pos = pos + 5
      return false
    elseif str:sub(pos, pos + 3) == "null" then
      pos = pos + 4
      return nil
    else
      -- Parse number
      local start = pos
      while pos <= #str and str:sub(pos, pos):match("[%d%.eE+%-]") do
        pos = pos + 1
      end
      return tonumber(str:sub(start, pos - 1))
    end
  end
  
  return parse_value()
end

-- AI Copilot configuration
config.plugins.aicopilot = common.merge({
  enabled = true,
  api_endpoint = "https://api.openai.com/v1/chat/completions",
  api_key = "",
  model = "gpt-4",
  max_tokens = 2000,
  temperature = 0.7,
  mode = "ask", -- ask, edit, yolo, plan
  mcp_enabled = false,
  mcp_servers = {},
  auto_apply_edits = false, -- For YOLO mode
  show_thinking = false,
  config_spec = {
    name = "AI Copilot",
    {
      label = "Enable AI Copilot",
      description = "Enable or disable the AI coding assistant.",
      path = "enabled",
      type = "toggle",
      default = true
    },
    {
      label = "API Endpoint",
      description = "OpenAI-compatible API endpoint URL.",
      path = "api_endpoint",
      type = "string",
      default = "https://api.openai.com/v1/chat/completions"
    },
    {
      label = "API Key",
      description = "Your OpenAI API key or compatible service key.",
      path = "api_key",
      type = "string",
      default = ""
    },
    {
      label = "Model",
      description = "Model name to use (e.g., gpt-4, gpt-3.5-turbo, claude-3-opus).",
      path = "model",
      type = "string",
      default = "gpt-4"
    },
    {
      label = "Max Tokens",
      description = "Maximum tokens in the response.",
      path = "max_tokens",
      type = "number",
      default = 2000,
      min = 100,
      max = 8000
    },
    {
      label = "Temperature",
      description = "Creativity level (0.0 - 2.0).",
      path = "temperature",
      type = "number",
      default = 0.7,
      min = 0.0,
      max = 2.0,
      step = 0.1
    },
    {
      label = "Default Mode",
      description = "Default interaction mode.",
      path = "mode",
      type = "selection",
      default = "ask",
      values = {
        {"Ask (Question Mode)", "ask"},
        {"Edit (Modify Code)", "edit"},
        {"YOLO (Auto-Apply)", "yolo"},
        {"Plan (Architecture)", "plan"}
      }
    },
    {
      label = "Enable MCP",
      description = "Enable Model Context Protocol server support.",
      path = "mcp_enabled",
      type = "toggle",
      default = false
    },
    {
      label = "Auto-Apply in YOLO",
      description = "Automatically apply code changes in YOLO mode without confirmation.",
      path = "auto_apply_edits",
      type = "toggle",
      default = false
    },
    {
      label = "Show Thinking",
      description = "Display AI reasoning process before answers.",
      path = "show_thinking",
      type = "toggle",
      default = false
    }
  }
}, config.plugins.aicopilot)

local aicopilot = {}
aicopilot.history = {}
aicopilot.current_request = nil

-- HTTP request function using curl
local function http_request(url, method, headers, body)
  local temp_file = os.tmpname()
  local header_args = ""
  
  for k, v in pairs(headers or {}) do
    header_args = header_args .. string.format(' -H "%s: %s"', k, v)
  end
  
  local curl_cmd = string.format(
    'curl -s -X %s %s %s -d \'%s\' -o "%s" -w "%%{http_code}"',
    method,
    header_args,
    url,
    body or "",
    temp_file
  )
  
  local handle = io.popen(curl_cmd)
  local status_code = handle:read("*a")
  handle:close()
  
  local file = io.open(temp_file, "r")
  local response = file:read("*a")
  file:close()
  os.remove(temp_file)
  
  return tonumber(status_code), response
end

-- Call OpenAI-compatible API
function aicopilot.call_api(messages, callback)
  if not config.plugins.aicopilot.api_key or config.plugins.aicopilot.api_key == "" then
    callback(false, "API key not configured. Please set it in Settings > AI Copilot.")
    return
  end
  
  local payload = {
    model = config.plugins.aicopilot.model,
    messages = messages,
    max_tokens = config.plugins.aicopilot.max_tokens,
    temperature = config.plugins.aicopilot.temperature,
    stream = false
  }
  
  core.add_thread(function()
    local status, response = http_request(
      config.plugins.aicopilot.api_endpoint,
      "POST",
      {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. config.plugins.aicopilot.api_key
      },
      json.encode(payload)
    )
    
    if status == 200 then
      local data = json.decode(response)
      if data and data.choices and data.choices[1] and data.choices[1].message then
        callback(true, data.choices[1].message.content)
      else
        callback(false, "Invalid API response format")
      end
    else
      callback(false, "API request failed with status " .. tostring(status) .. ": " .. response)
    end
  end)
end

-- Get context from current document
function aicopilot.get_document_context()
  local av = core.active_view
  if not av or not av.doc then
    return nil
  end
  
  local doc = av.doc
  local line1, col1, line2, col2 = doc:get_selection()
  local selected_text = doc:get_text(line1, col1, line2, col2)
  local full_text = doc:get_text(1, 1, #doc.lines, #doc.lines[#doc.lines])
  
  return {
    filename = doc.filename or "untitled",
    language = doc.syntax and doc.syntax.name or "text",
    selected = selected_text,
    full = full_text,
    cursor_line = line1,
    total_lines = #doc.lines
  }
end

-- ASK MODE: Ask a question about code
function aicopilot.ask_mode(prompt)
  local context = aicopilot.get_document_context()
  if not context then
    core.error("No active document")
    return
  end
  
  local system_message = "You are an AI coding assistant. Answer questions about code clearly and concisely."
  local user_message = string.format(
    "File: %s (%s)\n\nCurrent code:\n```\n%s\n```\n\nQuestion: %s",
    context.filename,
    context.language,
    context.selected ~= "" and context.selected or context.full,
    prompt
  )
  
  core.log("Asking AI...")
  
  aicopilot.call_api({
    {role = "system", content = system_message},
    {role = "user", content = user_message}
  }, function(success, response)
    if success then
      aicopilot.show_response("Ask Mode Response", response)
      table.insert(aicopilot.history, {mode = "ask", prompt = prompt, response = response})
    else
      core.error("AI request failed: " .. response)
    end
  end)
end

-- EDIT MODE: Modify code with AI suggestions
function aicopilot.edit_mode(instruction)
  local context = aicopilot.get_document_context()
  if not context then
    core.error("No active document")
    return
  end
  
  local code_to_edit = context.selected ~= "" and context.selected or context.full
  local system_message = "You are an AI coding assistant. Provide modified code based on the user's instruction. Return ONLY the modified code without explanations, wrapped in markdown code block."
  local user_message = string.format(
    "Language: %s\n\nCurrent code:\n```%s\n%s\n```\n\nInstruction: %s\n\nProvide the complete modified code.",
    context.language,
    context.language,
    code_to_edit,
    instruction
  )
  
  core.log("Processing edit request...")
  
  aicopilot.call_api({
    {role = "system", content = system_message},
    {role = "user", content = user_message}
  }, function(success, response)
    if success then
      -- Extract code from markdown block
      local code = response:match("```[%w]*\n(.-)```") or response
      aicopilot.show_edit_suggestion(code, context.selected ~= "")
      table.insert(aicopilot.history, {mode = "edit", instruction = instruction, response = response})
    else
      core.error("AI request failed: " .. response)
    end
  end)
end

-- YOLO MODE: Auto-apply AI edits without confirmation
function aicopilot.yolo_mode(instruction)
  local context = aicopilot.get_document_context()
  if not context then
    core.error("No active document")
    return
  end
  
  local code_to_edit = context.selected ~= "" and context.selected or context.full
  local system_message = "You are an AI coding assistant. Provide modified code based on the user's instruction. Return ONLY the modified code without explanations."
  local user_message = string.format(
    "Language: %s\n\nCurrent code:\n```%s\n%s\n```\n\nInstruction: %s",
    context.language,
    context.language,
    code_to_edit,
    instruction
  )
  
  core.log("YOLO mode: Processing...")
  
  aicopilot.call_api({
    {role = "system", content = system_message},
    {role = "user", content = user_message}
  }, function(success, response)
    if success then
      local code = response:match("```[%w]*\n(.-)```") or response
      
      if config.plugins.aicopilot.auto_apply_edits then
        aicopilot.apply_code(code, context.selected ~= "")
        core.log("YOLO: Code applied automatically!")
      else
        aicopilot.show_edit_suggestion(code, context.selected ~= "", true)
      end
      
      table.insert(aicopilot.history, {mode = "yolo", instruction = instruction, response = response})
    else
      core.error("AI request failed: " .. response)
    end
  end)
end

-- PLAN MODE: Generate architecture and planning
function aicopilot.plan_mode(request)
  local context = aicopilot.get_document_context()
  
  local system_message = "You are an AI architecture and planning assistant. Provide detailed plans, architecture designs, and implementation strategies."
  local user_message = request
  
  if context then
    user_message = string.format(
      "Context - File: %s (%s)\n\n%s",
      context.filename,
      context.language,
      request
    )
  end
  
  core.log("Planning with AI...")
  
  aicopilot.call_api({
    {role = "system", content = system_message},
    {role = "user", content = user_message}
  }, function(success, response)
    if success then
      aicopilot.show_response("Plan Mode Response", response)
      table.insert(aicopilot.history, {mode = "plan", request = request, response = response})
    else
      core.error("AI request failed: " .. response)
    end
  end)
end

-- Apply code to document
function aicopilot.apply_code(code, replace_selection)
  local av = core.active_view
  if not av or not av.doc then return end
  
  local doc = av.doc
  
  if replace_selection then
    doc:replace(function(text)
      return code
    end)
  else
    doc:remove(1, 1, #doc.lines, #doc.lines[#doc.lines])
    doc:insert(1, 1, code)
  end
  
  core.log("Code applied successfully")
end

-- Show response in a message dialog
function aicopilot.show_response(title, content)
  -- Create a simple log view with the response
  core.log_quiet(string.format("\n=== %s ===\n%s\n================\n", title, content))
  core.log("AI response logged. Check the log view for details.")
  
  -- Also try to show in a doc if possible
  local doc = Doc()
  doc:insert(1, 1, content)
  core.root_view:open_doc(doc)
end

-- Show edit suggestion with option to apply
function aicopilot.show_edit_suggestion(code, is_selection, is_yolo)
  local doc = Doc()
  local header = is_yolo and "=== YOLO MODE - CODE SUGGESTION ===\n\n" or "=== EDIT SUGGESTION ===\n\n"
  doc:insert(1, 1, header .. code .. "\n\n" .. (is_yolo and "Auto-apply: " .. tostring(config.plugins.aicopilot.auto_apply_edits) : "Use 'AI Copilot: Apply Suggestion' to apply this code."))
  core.root_view:open_doc(doc)
  
  -- Store for later application
  aicopilot.last_suggestion = {code = code, is_selection = is_selection}
end

-- MCP Server integration (basic structure)
function aicopilot.mcp_call(server_name, method, params)
  if not config.plugins.aicopilot.mcp_enabled then
    core.error("MCP is not enabled")
    return
  end
  
  -- Basic MCP implementation - would need actual MCP protocol
  core.log("MCP call to " .. server_name .. "." .. method .. " (not fully implemented)")
end

-- Commands
command.add(nil, {
  ["ai-copilot:ask"] = function()
    core.command_view:enter("AI Copilot - Ask", {
      submit = function(text)
        aicopilot.ask_mode(text)
      end
    })
  end,
  
  ["ai-copilot:edit"] = function()
    core.command_view:enter("AI Copilot - Edit Instruction", {
      submit = function(text)
        aicopilot.edit_mode(text)
      end
    })
  end,
  
  ["ai-copilot:yolo"] = function()
    core.command_view:enter("AI Copilot - YOLO Mode Instruction", {
      submit = function(text)
        aicopilot.yolo_mode(text)
      end
    })
  end,
  
  ["ai-copilot:plan"] = function()
    core.command_view:enter("AI Copilot - Planning Request", {
      submit = function(text)
        aicopilot.plan_mode(text)
      end
    })
  end,
  
  ["ai-copilot:apply-suggestion"] = function()
    if aicopilot.last_suggestion then
      aicopilot.apply_code(aicopilot.last_suggestion.code, aicopilot.last_suggestion.is_selection)
      aicopilot.last_suggestion = nil
    else
      core.error("No suggestion to apply")
    end
  end,
  
  ["ai-copilot:set-mode-ask"] = function()
    config.plugins.aicopilot.mode = "ask"
    core.log("AI Copilot mode: Ask")
  end,
  
  ["ai-copilot:set-mode-edit"] = function()
    config.plugins.aicopilot.mode = "edit"
    core.log("AI Copilot mode: Edit")
  end,
  
  ["ai-copilot:set-mode-yolo"] = function()
    config.plugins.aicopilot.mode = "yolo"
    core.log("AI Copilot mode: YOLO")
  end,
  
  ["ai-copilot:set-mode-plan"] = function()
    config.plugins.aicopilot.mode = "plan"
    core.log("AI Copilot mode: Plan")
  end,
  
  ["ai-copilot:quick-prompt"] = function()
    core.command_view:enter("AI Copilot (" .. config.plugins.aicopilot.mode .. ")", {
      submit = function(text)
        local mode = config.plugins.aicopilot.mode
        if mode == "ask" then
          aicopilot.ask_mode(text)
        elseif mode == "edit" then
          aicopilot.edit_mode(text)
        elseif mode == "yolo" then
          aicopilot.yolo_mode(text)
        elseif mode == "plan" then
          aicopilot.plan_mode(text)
        end
      end
    })
  end,
  
  ["ai-copilot:clear-history"] = function()
    aicopilot.history = {}
    core.log("AI Copilot history cleared")
  end
})

-- Keybindings
keymap.add {
  ["ctrl+alt+a"] = "ai-copilot:ask",
  ["ctrl+alt+e"] = "ai-copilot:edit",
  ["ctrl+alt+y"] = "ai-copilot:yolo",
  ["ctrl+alt+p"] = "ai-copilot:plan",
  ["ctrl+alt+space"] = "ai-copilot:quick-prompt",
  ["ctrl+alt+shift+a"] = "ai-copilot:apply-suggestion"
}

core.log_quiet("AI Copilot loaded. Quick access: Ctrl+Alt+Space")

return aicopilot
