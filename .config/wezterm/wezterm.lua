local wezterm = require("wezterm")
local projects = require("projects")
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

local config = wezterm.config_builder()
config:set_strict_mode(true)

-- Misc
config.set_environment_variables = {
	PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
}
config.enable_scroll_bar = true
config.initial_cols = 140
config.initial_rows = 40

-- Color Scheme
config.color_scheme = "Kanagawa (Gogh)"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.native_macos_fullscreen_mode = true
config.macos_window_background_blur = 80
config.window_frame = {
	font = wezterm.font({ family = "Monaspace Neon", weight = "Bold" }),
	font_size = 12.0,
	active_titlebar_bg = "transparent",
	inactive_titlebar_bg = "transparent",
}

local bg_path = "/Users/" .. os.getenv("USER") .. "/.config/wezterm/backgrounds/kuniyoshi.jpg"
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
config.background = {
	{
		source = {
			File = bg_path,
		},
		width = "100%",
		hsb = {
			hue = 1.0,
			saturation = 1.20,
			brightness = 0.25,
		},
	},
	{
		source = {
			Color = scheme.background,
		},
		width = "100%",
		height = "100%",
		opacity = 0.95,
	},
}

-- Text
config.font = wezterm.font_with_fallback({
	{
		family = "Monaspace Neon",
		harfbuzz_features = { "calt", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08", "liga" },
		weight = "Medium",
	},
	{
		family = "MesloLGS NF",
		weight = "Medium",
	},
})
config.font_size = 14.0
config.line_height = 1.2
config.freetype_load_flags = "NO_HINTING|MONOCHROME"
config.font_rules = {
	{ -- Italic
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = "Monaspace Radon",
			style = "Italic",
		}),
	},

	{ -- Bold
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = "Monaspace Argon",
			weight = "Bold",
		}),
	},

	{ -- Bold Italic
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = "Monaspace Neon",
			style = "Italic",
			weight = "Bold",
		}),
	},
}

-- Key helpers
local function move_pane(key, direction)
	return {
		key = key,
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection(direction),
	}
end

local function resize_pane(key, direction)
	return {
		key = key,
		action = wezterm.action.AdjustPaneSize({ direction, 3 }),
	}
end

-- Keys
config.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}
config.keys = {
	{
		key = "a",
		-- When we're in leader mode _and_ CTRL + A is pressed...
		mods = "LEADER|CTRL",
		-- Actually send CTRL + A key to the terminal
		action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
	},
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bb"),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bf"),
	},
	{
		key = ",",
		mods = "SUPER",
		action = wezterm.action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = { "nvim", wezterm.config_file },
		}),
	},
	{
		key = '"',
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "%",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	move_pane("j", "Down"),
	move_pane("k", "Up"),
	move_pane("h", "Left"),
	move_pane("l", "Right"),
	{
		key = "r",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "resize_panes",
			one_shot = false,
			timeout_milliseconds = 1000,
		}),
	},
	{
		key = "p",
		mods = "LEADER",
		action = projects.choose_project(),
	},
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
}

config.key_tables = {
	resize_panes = {
		resize_pane("j", "Down"),
		resize_pane("k", "Up"),
		resize_pane("h", "Left"),
		resize_pane("l", "Right"),
	},
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 9,
	bottom = 0,
}

-- Bar
bar.apply_to_config(config, {
	enabled_modules = {
		pane = false,
	},
	ansi_colors = {
		workspace = 5,
		active_tab = 2,
		inactive_tab = 8,
	},
})
config.show_new_tab_button_in_tab_bar = false

return config
