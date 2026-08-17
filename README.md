<h1 align=center>nerii-shell</h1>

<div align=center>

![GitHub last commit](https://img.shields.io/github/last-commit/neriidesu/nerii-shell?style=for-the-badge&labelColor=1E2326&color=A7C080) ![GitHub Repo stars](https://img.shields.io/github/stars/neriidesu/nerii-shell?style=for-the-badge&labelColor=1E2326&color=D699B6) ![GitHub repo size](https://img.shields.io/github/repo-size/neriidesu/nerii-shell?style=for-the-badge&labelColor=1E2326&color=E69875)

### highly opinionated shell built with quickshell for hyprland
*Loosely based on backend from noctalia-v4*

</div>

---
## What is it?
nerii-shell is a highly opinionated shell (in that the features it includes are there because i wanted them to be there) built with [quickshell](https://quickshell.org/) for [hyprland](https://hypr.land). The initial backend for some components where referenced from [noctalia's](https://noctalia.dev) [legacy v4](https://github.com/noctalia-dev/noctalia/tree/legacy-v4) branch.
## What is it not?
nerii-shell is **not** a drop-in replacement for major shells like noctalia. For one, it only works with hyprland, and will always only work with hyprland, unless i switch to a different compositor. It is slighly customizable, as it has a config file, but it will not fit every purpose, nor will it have a config option for everything.

## Features

- Two different themes
- Top bar with widgets for common stuff like workspaces, media, clock, audio, etc
- Fully* featured IPC
- Wallpaper selector

\*fully enough

# Installation

If you've read all of this and decided you want to install nerii-shell, follow the instructions below. 

> [!NOTE]
> This guide assumes you know a little bit about what you're doing. It also assumes you are running an Arch-based distro, but it should work on any distro that supports quickshell and hyprland.

## Prerequisites

nerii-shell uses a few different programs to not have to handle everything itself. Make sure you have these installed. You can also use the following command to install them:

`sudo pacman -S hyprland hyprpaper hyprlock quickshell matugen cliphist pipewire imagemagick`

nerii-shell optionally supports [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) for animated wallpapers. Install it from source or from the AUR, with or without your AUR helper of choice. The shell will still work without it.

## Installation

Clone this git repository into quickshell's config directory:

`cd ~/.config/quickshell && git clone https://github.com/neriidesu/nerii-shell.git`

Add the following to the top hyprland.lua:

```lua
ipc = "qs -c nerii-shell ipc call"
menu = ipc .. " launcher toggle"
```

Add `hl.exec_cmd("qs -c nerii-shell")` to your hyprland.start

```lua
hl.on("hyprland.start", function()
    ...
    `hl.exec_cmd("qs -c nerii-shell")`
end)
```

Set `QS_ICON_THEME` to your preferred icon theme

```lua
hl.env("QS_ICON_THEME", "hicolor")
```

Add the following keybinds:

```lua
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. " media playPause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. " media playPause"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume increase"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume decrease"))

hl.bind(mainMod .. " + W",hl.dsp.exec_cmd(ipc .. " panel toggle wallpaperPanel"))
hl.bind(mainMod .. " + X",hl.dsp.exec_cmd(ipc .. " launcher clipboard"))
```

You can also add layer rules as normal. 

```lua
--- blur background of all nerii-shell layers
hl.layer_rule({ match = { namespace = "nerii-shell.+" }, blur = true, ignore_alpha = false})
```

The naming convention for shell layers is as follows:

Bar: nerii-shell-bar-[SCREEN NAME]
Launcher: nerii-shell-launcher-overlay-[SCREEN NAME]
Panels: nerii-shell-background-[SCREEN NAME]
Popup menu: nerii-shell-popupmenu-[SCREEN NAME]

## Configuration

Configuration is done in JSON. The config file is located at `~/.config/nerii-shell/config.json`

> [!NOTE]
> For wallpaper selection to work please set `wallpaperDir` to an absolute path to your wallpaper directory. Usually this would be `/home/USER/Pictures/Wallpapers/`

For more configuration options, please read [this](https://github.com/neriidesu/nerii-shell/tree/master/CONFIGURATION.md) document

# Thanks

- [quickshell](https://quickshell.org/) this would still be waybar and wofi with some bash scripts without it.
- [Noctalia](https://noctalia.dev) whose v4-branch I learned most of my quickshell from
- [caelestia](https://caelestiashell.com/) which I saw quickshell used firstly, and based this README off.