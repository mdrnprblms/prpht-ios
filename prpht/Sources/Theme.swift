//
//  Theme.swift
//  prpht
//
//  Brand tokens ported from the web app's CSS variables.
//

import SwiftUI

enum Brand {
    static let whiteGrape   = Color(hex: 0xA6BE47)   // Pantone White Grape
    static let darkAccent   = Color(hex: 0x8FB026)   // dark-mode accent
    static let textBrand    = Color(hex: 0x3E5210)   // light-mode brand text
    static let winGreen     = Color(hex: 0x61AD34)
    static let bgLight      = Color(hex: 0xFCF4F6)   // lavender-blush white
    static let bgDark       = Color(hex: 0x040403)   // palette anchor black
    static let sageLight    = Color(hex: 0xF4F8E8)
    static let sageBorder   = Color(hex: 0xDCE8C0)

    /// Accent that adapts to color scheme, mirroring the web override.
    static func accent(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkAccent : whiteGrape
    }
    /// Brand colour for text/icons with contrast override in light mode.
    static func brandText(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkAccent : textBrand
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    init(hexString: String) {
        var s = hexString.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        self.init(hex: UInt32(v))
    }

    var hexString: String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

/// Ambient blob-field wash palette (saturated companions).
enum Wash {
    static let graniteGreen = Color(red: 63/255, green: 146/255, blue: 114/255)
    static let lavenderBlue = Color(red: 122/255, green: 134/255, blue: 204/255)
    static let pacificCyan  = Color(red: 61/255, green: 147/255, blue: 166/255)
    static let wisteriaBlue = Color(red: 138/255, green: 164/255, blue: 224/255)
}

func money(_ n: Double) -> String {
    String(format: "£%.2f", n)
}

// MARK: - Zalando Sans Expanded (ported typeface)
//
// The web only loads 300/600/900, so CSS font matching resolves any other
// weight to the nearest of those three (see prpht.html's stylesheet
// comments) rather than synthesizing a bold. `zalando` mirrors that: it
// snaps every SwiftUI weight down to one of the three real static faces.

enum ZFont {
    static let light    = "ZalandoSansExpanded-Light"
    static let semibold = "ZalandoSansExpanded-SemiBold"
    static let black    = "ZalandoSansExpanded-Black"
}

func zalando(_ weight: Font.Weight, _ size: CGFloat) -> Font {
    switch weight {
    case .medium, .semibold:
        return .custom(ZFont.semibold, size: size)
    case .bold, .heavy, .black:
        return .custom(ZFont.black, size: size)
    default:
        return .custom(ZFont.light, size: size)
    }
}

// MARK: - Sport icon artwork (real icons scraped from the web app; the
// prediction-market categories and "For You" have no icon-*.svg on the web
// either, so they fall back to the same SF Symbol / colour dot everywhere.)

func sportIconAssetName(_ sport: String) -> String? {
    switch sport {
    case "Football":     return "IconFootball"
    case "Basketball":   return "IconBasketball"
    case "Cricket":      return "IconCricket"
    case "Racing":       return "IconRacing"
    case "Tennis":       return "IconTennis"
    case "Love Island":  return "IconLoveIsland"
    default:             return nil
    }
}
