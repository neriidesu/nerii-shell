# Configuration
You can configure nerii-shell by editing the config file at `~/.config/nerii-shell/config.json`.

The default configuration is:

```json
{
  "misc": {
    "debug": false,
    "theme": ""
  },
  "bar": {
    "showBattery": true,
    "showWifi": true,
    "showEth": true,
    "blacklistTrayIds": []
  },
  "media": {
    "preferredPlayer": ""
  },
  "weather": {
    "locationName": "",
    "updateWeather": true
  },
  "wallpaper": {
    "wallpaperPath": "",
    "wallpaperDir": "",
    "lweDir": "",
    "enableLwe": false
  },
  "appLauncher": {
    "terminalCommand": "kitty"
  },
  "colors": {
    "genFromWallpaper": true,
    "genFromColor": false,
    "genWithTheme": false,
    "themeName": "",
    "themeDir": "",
    "primaryHex": ""
  }
}
```

Note that this doesn't include everything. Please check the list below for more options

## Information about options

### Misc
#### debug
Wether to show debug-level logs in quickshell console
#### theme
What theme to use for the shell. Leave empty to use default theme values. Options: `"sleek", "rect"`

### Bar
#### showBattery, showWifi, showEth
Wether to show respective element.
#### blacklistTrayIds
Array of app ids to hide from tray menu. Example: `["spotify-client"]`
#### keepWorkspaces
JSON object of what workspaces to show even if they're empty, per-monitor. Equivalent of waybar's persistent-workspaces. Example: `{"DP-2": [1,10],"DP-3": [2,3,4]},`
#### workspaceIcons
JSON object of special icons for workspaces. Example: `{"3": "","4": ""}`

### Media
#### preferredPlayer
Preferred media player for media widget and controls.

### Weather
#### locationName
Comma-separated location name for weather. Example: `"Tokyo,Japan"`
#### updateWeather
Wether to update weather or not

### Wallpaper
#### wallpaperPath
Absolute path to selected wallpaper. 
#### wallpaperDir
Directory where wallpapers are located
#### lweDir
Directory where previews of linux-wallpaperengine wallpapers should be placed.
#### enableLwe
Wether to enable linux-wallpaperengine wallpapers

### App Launcher
#### terminalCommand
What command to use when running terminal commands through >cmd handler.

### Colors
#### genFromWallpaper
Wether to generate matugen colors from wallpaper. Takes priority over genFromColor and genWithTheme
#### genFromColor
Wether to generate matugen colors from primaryHex. Takes priority over genWithTheme
#### genWithTheme
Wether to use a preset theme to generate matugen colors. These are JSON files replacing all core matugen colors. Example can be found [here](https://github.com/neriidesu/nerii-shell/tree/master/Examples/matugenThemes)
#### themeName
Name of theme to use. Example: `"catppuccin-mocha"`
#### themeDir
Absoltue path to directory where preset themes reside.
#### primaryHex
Hex code to base genFromColor and genWithTheme on. Example: `"#cba6f7"`