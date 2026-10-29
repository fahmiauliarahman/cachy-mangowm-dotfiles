-- Native colorscheme derived from the active MangoWM Quattro palette.
local state_home = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
local state = state_home .. "/mango/theme.json"

local fallback = {
  mode = "dark", accent = "#81a1c1", selection = "#434c5e", muted = "#4c566a",
  background = "#2e3440", dark_background = "#222730", darker_background = "#191c23",
  lighter_background = "#3b4252", foreground = "#d8dee9", dark_foreground = "#667080",
  light_foreground = "#adb5c4", red = "#bf616a", yellow = "#ebcb8b",
  green = "#a3be8c", cyan = "#88c0d0", blue = "#81a1c1", magenta = "#b48ead",
}

local function load_palette()
  local file = io.open(state, "r")
  if not file then
    return fallback
  end
  local data = file:read("*a")
  file:close()
  local ok, palette = pcall(vim.json.decode, data)
  return ok and type(palette) == "table" and palette or fallback
end

local function apply()
  local c = load_palette()
  vim.o.background = c.mode
  vim.cmd.highlight("clear")
  vim.g.colors_name = "mango"
  local hl = function(group, style) vim.api.nvim_set_hl(0, group, style) end
  hl("Normal", { fg = c.foreground, bg = c.background })
  hl("NormalFloat", { fg = c.foreground, bg = c.dark_background })
  hl("FloatBorder", { fg = c.accent, bg = c.dark_background })
  hl("SignColumn", { fg = c.muted, bg = c.background })
  hl("LineNr", { fg = c.dark_foreground })
  hl("CursorLineNr", { fg = c.accent, bold = true })
  hl("CursorLine", { bg = c.lighter_background })
  hl("Visual", { bg = c.selection })
  hl("Search", { fg = c.background, bg = c.yellow })
  hl("IncSearch", { fg = c.background, bg = c.accent })
  hl("StatusLine", { fg = c.foreground, bg = c.dark_background })
  hl("StatusLineNC", { fg = c.dark_foreground, bg = c.dark_background })
  hl("Pmenu", { fg = c.foreground, bg = c.dark_background })
  hl("PmenuSel", { fg = c.foreground, bg = c.selection })
  hl("Comment", { fg = c.dark_foreground, italic = true })
  hl("Constant", { fg = c.magenta })
  hl("String", { fg = c.green })
  hl("Number", { fg = c.orange or c.yellow })
  hl("Identifier", { fg = c.foreground })
  hl("Function", { fg = c.blue })
  hl("Statement", { fg = c.magenta })
  hl("Keyword", { fg = c.magenta })
  hl("PreProc", { fg = c.yellow })
  hl("Type", { fg = c.cyan })
  hl("Special", { fg = c.accent })
  hl("Error", { fg = c.red })
  hl("DiagnosticError", { fg = c.red })
  hl("DiagnosticWarn", { fg = c.yellow })
  hl("DiagnosticInfo", { fg = c.blue })
  hl("DiagnosticHint", { fg = c.cyan })
  hl("DiffAdd", { fg = c.green, bg = c.dark_background })
  hl("DiffDelete", { fg = c.red, bg = c.dark_background })
  hl("DiffChange", { fg = c.blue, bg = c.dark_background })
  hl("@variable", { fg = c.foreground })
  hl("@function", { fg = c.blue })
  hl("@keyword", { fg = c.magenta })
  hl("@string", { fg = c.green })
  hl("@type", { fg = c.cyan })
end

apply()

-- Existing editors pick up external theme changes without a restart.
local group = vim.api.nvim_create_augroup("MangoTheme", { clear = true })
local timer = vim.uv.new_timer()
local seen = (vim.uv.fs_stat(state) or {}).mtime
local function changed()
  local stat = vim.uv.fs_stat(state)
  local mtime = stat and stat.mtime
  if mtime and (not seen or mtime.sec ~= seen.sec or mtime.nsec ~= seen.nsec) then
    seen = mtime
    apply()
  end
end
timer:start(2000, 2000, vim.schedule_wrap(changed))
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function() timer:stop(); timer:close() end,
})
