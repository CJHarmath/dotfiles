-- ~/.config/wezterm/wezterm.lua
-- The future of terminal emulators, today

local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- Performance: GPU acceleration is non-negotiable
config.webgpu_preferred_adapter = {
  backend = 'Vulkan',
  device_type = 'DiscreteGpu',
}
config.front_end = 'WebGpu'
config.max_fps = 120

-- Font: Monaspace Neon with fallbacks
config.font = wezterm.font_with_fallback {
  {
    family = 'Monaspace Neon',
    weight = 'Regular',
    harfbuzz_features = { 'calt=1', 'liga=1', 'dlig=1', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
  },
  'JetBrains Mono',
  'Noto Color Emoji',
}
config.font_size = 14.0
config.line_height = 1.2
config.use_cap_height_to_scale_fallback_fonts = true

-- Color scheme: Catppuccin Mocha (the only correct choice)
config.color_scheme = 'Catppuccin Mocha'

-- Window configuration
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Tab bar (programmable, because we're not savages)
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- Custom tab bar formatting
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local edge_background = '#1e1e2e'
  local background = '#313244'
  local foreground = '#cdd6f4'

  if tab.is_active then
    background = '#f38ba8'
    foreground = '#1e1e2e'
  elseif hover then
    background = '#45475a'
  end

  local edge_foreground = background
  local title = wezterm.truncate_right(tab.tab_title, max_width - 2)

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = '' },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = ' ' .. title .. ' ' },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = '' },
  }
end)

-- Keybindings: The sauce that makes it all work
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- Split management (like tmux but better)
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  
  -- Pane navigation (vim-style, obviously)
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  
  -- Pane resizing
  { key = 'H', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'J', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'K', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'L', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize { 'Right', 5 } },
  
  -- Tab management
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  
  -- Copy mode (vim-style selection)
  { key = 'v', mods = 'LEADER', action = act.ActivateCopyMode },
  
  -- Quick actions
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'f', mods = 'LEADER', action = act.Search { CaseSensitiveString = '' } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  
  -- Command palette (the future is now)
  { key = 'P', mods = 'LEADER|SHIFT', action = act.ActivateCommandPalette },
  
  -- Quick launcher for common tasks
  { key = 'g', mods = 'LEADER', action = act.SpawnCommandInNewTab { args = { 'lazygit' } } },
  { key = 's', mods = 'LEADER', action = act.SpawnCommandInNewTab { args = { 'btm' } } },
}

-- Smart workspace switching
for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = act.ActivateTab(i - 1),
  })
end

-- Scrollback (because sometimes you need to see what happened)
config.scrollback_lines = 10000

-- Selection behavior
config.selection_word_boundary = ' \t\n{}[]()"\',;:'

-- URL detection and clicking
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- SSH domain auto-detection
config.ssh_domains = {}

-- Local overrides (because every setup is unique)
local success, local_config = pcall(require, 'local')
if success then
  for k, v in pairs(local_config) do
    config[k] = v
  end
end

return config