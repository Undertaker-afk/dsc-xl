# AI Copilot Plugin for Lite XL

A comprehensive AI-powered coding assistant with multiple interaction modes, OpenAI-compatible API support, and Model Context Protocol (MCP) integration.

## Features

### 🤖 Multiple Interaction Modes

1. **Ask Mode** - Question & Answer
   - Ask questions about your code
   - Get explanations and suggestions
   - Context-aware responses based on current file

2. **Edit Mode** - Code Modification
   - Request specific code changes
   - AI suggests modifications
   - Review before applying

3. **YOLO Mode** - Rapid Development
   - Fast code generation and modification
   - Optional auto-apply feature
   - Perfect for quick iterations

4. **Plan Mode** - Architecture & Design
   - Generate implementation plans
   - Design system architecture
   - Strategic code organization

### 🔌 API Integration

- **OpenAI-Compatible Endpoints**
  - Works with OpenAI, Azure OpenAI, Claude, and other compatible APIs
  - Configurable endpoint URLs
  - Support for various models (GPT-4, GPT-3.5, Claude, etc.)

- **Model Context Protocol (MCP)**
  - Basic MCP server support
  - Extensible for custom integrations
  - Future-ready for advanced features

### ⚙️ Configuration

All settings accessible via Settings GUI:
- API endpoint and key configuration
- Model selection and parameters
- Mode preferences
- Auto-apply settings
- MCP server configuration

## Installation

The plugin is pre-integrated in this distribution. No additional installation needed.

**Location:** `data/plugins/aicopilot.lua`

## Quick Start

### 1. Configure API

Open Settings > AI Copilot and set:
- **API Key**: Your OpenAI or compatible service API key
- **API Endpoint**: Default is OpenAI, change for other services
- **Model**: Choose your preferred model (gpt-4, gpt-3.5-turbo, etc.)

### 2. Usage

**Quick Access (Recommended):**
```
Ctrl+Alt+Space - Quick prompt in current mode
```

**Mode-Specific Commands:**
```
Ctrl+Alt+A - Ask mode
Ctrl+Alt+E - Edit mode
Ctrl+Alt+Y - YOLO mode
Ctrl+Alt+P - Plan mode
Ctrl+Alt+Shift+A - Apply suggestion
```

## Detailed Usage

### Ask Mode

Ask questions about your code:

1. Select code (optional) or work with full file
2. Press `Ctrl+Alt+A` or use `Ctrl+Alt+Space` with Ask mode
3. Type your question
4. Response opens in a new document

**Example questions:**
- "What does this function do?"
- "How can I optimize this loop?"
- "Are there any security issues?"
- "Explain this algorithm"

### Edit Mode

Request code modifications:

1. Select code to modify (or full file)
2. Press `Ctrl+Alt+E` or use `Ctrl+Alt+Space` with Edit mode
3. Describe the changes you want
4. Review the suggestion
5. Press `Ctrl+Alt+Shift+A` to apply

**Example instructions:**
- "Add error handling"
- "Refactor this to use async/await"
- "Add type hints"
- "Extract this into a separate function"

### YOLO Mode

Fast code generation without review:

1. Select context (optional)
2. Press `Ctrl+Alt+Y` or use `Ctrl+Alt+Space` with YOLO mode
3. Describe what you want
4. Code is suggested or auto-applied (based on settings)

**Use cases:**
- Rapid prototyping
- Quick boilerplate generation
- Fast iterations

**Safety:** Disable auto-apply in settings for review before application.

### Plan Mode

Architecture and planning assistance:

1. Press `Ctrl+Alt+P` or use `Ctrl+Alt+Space` with Plan mode
2. Describe your planning need
3. Get detailed architecture or implementation plan

**Example requests:**
- "Design a REST API for user management"
- "Plan the structure for a plugin system"
- "How should I organize this codebase?"
- "Create a testing strategy"

## Configuration Options

### API Settings

```lua
config.plugins.aicopilot.api_endpoint = "https://api.openai.com/v1/chat/completions"
config.plugins.aicopilot.api_key = "your-api-key"
config.plugins.aicopilot.model = "gpt-4"
```

**Supported Endpoints:**

1. **OpenAI** (default)
   ```
   https://api.openai.com/v1/chat/completions
   ```

2. **Azure OpenAI**
   ```
   https://YOUR-RESOURCE-NAME.openai.azure.com/openai/deployments/YOUR-DEPLOYMENT-NAME/chat/completions?api-version=2023-05-15
   ```

3. **Anthropic Claude** (via compatible proxy)
   ```
   https://api.anthropic.com/v1/messages
   ```

4. **Local LLM (LM Studio, Ollama, etc.)**
   ```
   http://localhost:1234/v1/chat/completions
   ```

### Model Parameters

- **Max Tokens**: 100-8000 (default: 2000)
- **Temperature**: 0.0-2.0 (default: 0.7)
  - Lower = more deterministic
  - Higher = more creative

### Mode Selection

- **Default Mode**: Choose preferred starting mode
- Switch modes anytime with commands or settings

### YOLO Mode Settings

- **Auto-Apply Edits**: Enable/disable automatic code application
  - Enabled: Code applied immediately (use with caution)
  - Disabled: Review before applying (recommended)

### Advanced Options

- **Show Thinking**: Display AI reasoning process
- **MCP Enabled**: Enable Model Context Protocol support

## MCP (Model Context Protocol) Support

Basic MCP infrastructure is included for future extensibility.

### Adding MCP Servers

```lua
config.plugins.aicopilot.mcp_servers = {
  {
    name = "filesystem",
    command = "mcp-server-filesystem",
    args = {"/path/to/workspace"}
  },
  {
    name = "git",
    command = "mcp-server-git",
    args = {}
  }
}
```

### MCP Call Example

```lua
aicopilot.mcp_call("filesystem", "read_file", {path = "/path/to/file"})
```

**Note:** Full MCP implementation requires additional server processes and protocol handling.

## Command Reference

### Direct Commands

- `ai-copilot:ask` - Start Ask mode prompt
- `ai-copilot:edit` - Start Edit mode prompt
- `ai-copilot:yolo` - Start YOLO mode prompt
- `ai-copilot:plan` - Start Plan mode prompt
- `ai-copilot:quick-prompt` - Quick prompt in current mode
- `ai-copilot:apply-suggestion` - Apply last AI suggestion

### Mode Switching

- `ai-copilot:set-mode-ask` - Switch to Ask mode
- `ai-copilot:set-mode-edit` - Switch to Edit mode
- `ai-copilot:set-mode-yolo` - Switch to YOLO mode
- `ai-copilot:set-mode-plan` - Switch to Plan mode

### Utility

- `ai-copilot:clear-history` - Clear conversation history

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+Space` | Quick prompt (current mode) |
| `Ctrl+Alt+A` | Ask mode |
| `Ctrl+Alt+E` | Edit mode |
| `Ctrl+Alt+Y` | YOLO mode |
| `Ctrl+Alt+P` | Plan mode |
| `Ctrl+Alt+Shift+A` | Apply suggestion |

**Note:** Customize keybindings via Settings > Keybindings

## Workflow Examples

### Example 1: Code Review

```
1. Open a file
2. Ctrl+Alt+A (Ask)
3. Type: "Review this code for bugs and improvements"
4. Read response in new document
```

### Example 2: Refactoring

```
1. Select code block
2. Ctrl+Alt+E (Edit)
3. Type: "Refactor to improve readability and add comments"
4. Review suggestion
5. Ctrl+Alt+Shift+A to apply
```

### Example 3: Quick Feature

```
1. Place cursor where you want new code
2. Ctrl+Alt+Y (YOLO)
3. Type: "Add a user authentication function"
4. Code appears instantly (or after review)
```

### Example 4: Project Planning

```
1. Ctrl+Alt+P (Plan)
2. Type: "Plan a plugin architecture for extensible commands"
3. Get detailed architecture document
```

## Privacy & Security

### API Key Safety

- API keys stored in config (not in code)
- Never commit API keys to version control
- Use environment variables for shared projects

### Data Privacy

- Code sent to configured API endpoint
- Review API provider's privacy policy
- Use local LLMs for sensitive code
- YOLO mode: Disable auto-apply for safety

## Troubleshooting

### "API key not configured"

**Solution:** Set API key in Settings > AI Copilot

### "API request failed with status 401"

**Cause:** Invalid API key  
**Solution:** Verify your API key is correct

### "API request failed with status 429"

**Cause:** Rate limit exceeded  
**Solution:** Wait and retry, or check API plan limits

### No response / Timeout

**Possible causes:**
- Network connectivity issues
- API endpoint unreachable
- Very large requests

**Solutions:**
- Check internet connection
- Verify endpoint URL
- Reduce max_tokens setting

### Code not applied

**Solution:** Use `Ctrl+Alt+Shift+A` after receiving suggestion

### MCP not working

**Note:** Full MCP support requires additional implementation and server processes.

## Performance Tips

1. **Use Selection**: Select specific code for faster responses
2. **Adjust Max Tokens**: Lower for faster responses
3. **Choose Appropriate Model**: 
   - GPT-3.5-turbo: Faster, cheaper
   - GPT-4: More capable, slower
4. **Local LLMs**: Use for unlimited requests

## Integration with Other Plugins

### Works with Console Plugin

Run AI-generated commands in the Console:
```
1. Generate script with AI Copilot
2. Copy to Console (Ctrl+.)
3. Execute
```

### Works with Git Control

Generate commit messages:
```
1. Ctrl+Alt+A
2. Type: "Generate a commit message for my changes"
```

### Works with Settings Plugin

All configuration via Settings GUI - no manual config editing needed.

## API Cost Management

### Estimated Costs (OpenAI pricing)

- GPT-3.5-turbo: ~$0.001-0.002 per request
- GPT-4: ~$0.03-0.06 per request

### Cost Reduction Tips

1. Use GPT-3.5-turbo for simple tasks
2. Select specific code instead of full files
3. Reduce max_tokens for shorter responses
4. Use local LLMs (free)

## Future Enhancements

Planned features:
- Full MCP protocol implementation
- Streaming responses
- Multi-turn conversations
- Code generation templates
- Custom prompt templates
- Inline suggestions
- Diff view for edits
- Undo/redo for AI changes

## Credits

- **Plugin:** Custom implementation for dsc-xl
- **Inspired by:** GitHub Copilot, Cursor IDE
- **API:** OpenAI and compatible services

## License

MIT License - Same as Lite XL

## Support

For issues or feature requests, please use the repository's issue tracker.

---

**Happy Coding with AI! 🚀**
