import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    property alias md3: jsonAdapter.md3
    property alias base16: jsonAdapter.base16
    property alias palette: jsonAdapter.palette
    property string foreground: "#D3C6AA" // on_background
    property string red: "#E67E80"
    property string yellow: "#DBBC7F"
    property string green: "#A7C080"
    property string blue: "#7FBBB3"
    property string purple: "#D699B6"
    property string mauve: "#cba6f7"
    property string aqua: "#83C092"
    property string orange: "#E69875"
    property string status_ok: "#A7C080"
    property string status_pending: "#D3C6AA"
    property string status_err: "#E67E80" // error
    property string grey_0: "#7A8478"
    property string grey_1: "#859289"
    property string grey_2: "#9DA9A0"
    property string background_dim: "#1E2326" // surface
    property string background_0: "#272E33" // background
    property string background_1: "#2E383C" // surface_container_lowest
    property string background_2: "#374145" // surface_container_low
    property string background_3: "#414B50" // surface_container
    property string background_4: "#495156" // surface_container_high
    property string background_5: "#4F5B58" // surface_container_highest
    property string background_red: "#493B40"
    property string background_yellow: "#45443C"
    property string background_green: "#3C4841"
    property string background_blue: "#384B55"
    property string background_purple: "#463F48"
    property string background_visual: "#4C3743"
    property string mOnHover: Qt.alpha(md3.primary, 0.5)

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/quickshell/generated/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonAdapter

            readonly property Md3
            md3: Md3 {
            }

            readonly property Base16
            base16: Base16 {
            }

            readonly property Palette
            palette: Palette {
            }

        }

    }

    component Md3: JsonObject {
        property string background: "transparent"
        property string error: "transparent"
        property string error_container: "transparent"
        property string inverse_on_surface: "transparent"
        property string inverse_primary: "transparent"
        property string inverse_surface: "transparent"
        property string on_background: "transparent"
        property string on_error: "transparent"
        property string on_error_container: "transparent"
        property string on_primary: "transparent"
        property string on_primary_container: "transparent"
        property string on_primary_fixed: "transparent"
        property string on_primary_fixed_variant: "transparent"
        property string on_secondary: "transparent"
        property string on_secondary_container: "transparent"
        property string on_secondary_fixed: "transparent"
        property string on_secondary_fixed_variant: "transparent"
        property string on_surface: "transparent"
        property string on_surface_variant: "transparent"
        property string on_tertiary: "transparent"
        property string on_tertiary_container: "transparent"
        property string on_tertiary_fixed: "transparent"
        property string on_tertiary_fixed_variant: "transparent"
        property string outline: "transparent"
        property string outline_variant: "transparent"
        property string primary: "transparent"
        property string primary_container: "transparent"
        property string primary_fixed: "transparent"
        property string primary_fixed_dim: "transparent"
        property string scrim: "transparent"
        property string secondary: "transparent"
        property string secondary_container: "transparent"
        property string secondary_fixed: "transparent"
        property string secondary_fixed_dim: "transparent"
        property string shadow: "transparent"
        property string surface: "transparent"
        property string surface_bright: "transparent"
        property string surface_container: "transparent"
        property string surface_container_high: "transparent"
        property string surface_container_highest: "transparent"
        property string surface_container_low: "transparent"
        property string surface_container_lowest: "transparent"
        property string surface_dim: "transparent"
        property string surface_tint: "transparent"
        property string surface_variant: "transparent"
        property string tertiary: "transparent"
        property string tertiary_container: "transparent"
        property string tertiary_fixed: "transparent"
        property string tertiary_fixed_dim: "transparent"
    }

    component Palette: JsonObject {
        property string error0: "transparent"
        property string error5: "transparent"
        property string error10: "transparent"
        property string error15: "transparent"
        property string error20: "transparent"
        property string error25: "transparent"
        property string error30: "transparent"
        property string error35: "transparent"
        property string error40: "transparent"
        property string error50: "transparent"
        property string error60: "transparent"
        property string error70: "transparent"
        property string error80: "transpaimport QtQuick
import Quickshell
import Quickshell.Iorent"
        property string error90: "transparent"
        property string error95: "transparent"
        property string error98: "transparent"
        property string error99: "transparent"
        property string error100: "transparent"
        property string neutral0: "transparent"
        property string neutral5: "transparent"
        property string neutral10: "transparent"
        property string neutral15: "transparent"
        property string neutral20: "transparent"
        property string neutral25: "transparent"
        property string neutral30: "transparent"
        property string neutral35: "transparent"
        property string neutral40: "transparent"
        property string neutral50: "transparent"
        property string neutral60: "transparent"
        property string neutral70: "transparent"
        property string neutral80: "transparent"
        property string neutral90: "transparent"
        property string neutral95: "transparent"
        property string neutral98: "transparent"
        property string neutral99: "transparent"
        property string neutral100: "transparent"
        property string neutral_variant0: "transparent"
        property string neutral_variant5: "transparent"
        property string neutral_variant10: "transparent"
        property string neutral_variant15: "transparent"
        property string neutral_variant20: "transparent"
        property string neutral_variant25: "transparent"
        property string neutral_variant30: "transparent"
        property string neutral_variant35: "transparent"
        property string neutral_variant40: "transparent"
        property string neutral_variant50: "transparent"
        property string neutral_variant60: "transparent"
        property string neutral_variant70: "transparent"
        property string neutral_variant80: "transparent"
        property string neutral_variant90: "transparent"
        property string neutral_variant95: "transparent"
        property string neutral_variant98: "transparent"
        property string neutral_variant99: "transparent"
        property string neutral_variant100: "transparent"
        property string primary0: "transparent"
        property string primary5: "transparent"
        property string primary10: "transparent"
        property string primary15: "transparent"
        property string primary20: "transparent"
        property string primary25: "transparent"
        property string primary30: "transparent"
        property string primary35: "transparent"
        property string primary40: "transparent"
        property string primary50: "transparent"
        property string primary60: "transparent"
        property string primary70: "transparent"
        property string primary80: "transparent"
        property string primary90: "transparent"
        property string primary95: "transparent"
        property string primary98: "transparent"
        property string primary99: "transparent"
        property string primary100: "transparent"
        property string secondary0: "transparent"
        property string secondary5: "transparent"
        property string secondary10: "transparent"
        property string secondary15: "transparent"
        property string secondary20: "transparent"
        property string secondary25: "transparent"
        property string secondary30: "transparent"
        property string secondary35: "transparent"
        property string secondary40: "transparent"
        property string secondary50: "transparent"
        property string secondary60: "transparent"
        property string secondary70: "transparent"
        property string secondary80: "transparent"
        property string secondary90: "transparent"
        property string secondary95: "transparent"
        property string secondary98: "transparent"
        property string secondary99: "transparent"
        property string secondary100: "transparent"
        property string tertiary0: "transparent"
        property string tertiary5: "transparent"
        property string tertiary10: "transparent"
        property string tertiary15: "transparent"
        property string tertiary20: "transparent"
        property string tertiary25: "transparent"
        property string tertiary30: "transparent"
        property string tertiary35: "transparent"
        property string tertiary40: "transparent"
        property string tertiary50: "transparent"
        property string tertiary60: "transparent"
        property string tertiary70: "transparent"
        property string tertiary80: "transparent"
        property string tertiary90: "transparent"
        property string tertiary95: "transparent"
        property string tertiary98: "transparent"
        property string tertiary99: "transparent"
        property string tertiary100: "transparent"
    }

    component Base16: JsonObject {
        property string base00: "transparent"
        property string base01: "transparent"
        property string base02: "transparent"
        property string base03: "transparent"
        property string base04: "transparent"
        property string base05: "transparent"
        property string base06: "transparent"
        property string base07: "transparent"
        property string base08: "transparent"
        property string base09: "transparent"
        property string base0a: "transparent"
        property string base0b: "transparent"
        property string base0c: "transparent"
        property string base0d: "transparent"
        property string base0e: "transparent"
        property string base0f: "transparent"
    }

}
