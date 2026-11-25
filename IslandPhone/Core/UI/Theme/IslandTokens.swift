import SwiftUI

extension Color {
    init(argb: UInt32) {
        let a = Double((argb >> 24) & 0xFF) / 255.0
        let r = Double((argb >> 16) & 0xFF) / 255.0
        let g = Double((argb >> 8) & 0xFF) / 255.0
        let b = Double(argb & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

struct GlassTokens {
    var tint: Color
    var tintFallback: Color
    var highlight: Color
    var rimLight: Color
    var rimDark: Color
    var shadow: Color
    var innerShade: Color
    var edgeDark: Color
    var ambient: Color

    static let day = GlassTokens(
        tint: Color(argb: 0x1FFFFFFF),
        tintFallback: Color(argb: 0x66FFFFFF),
        highlight: Color(argb: 0x40FFFFFF),
        rimLight: Color(argb: 0xD9FFFFFF),
        rimDark: Color(argb: 0x26FFFFFF),
        shadow: Color(argb: 0x33000000),
        innerShade: Color(argb: 0x22203040),
        edgeDark: Color(argb: 0x4D000000),
        ambient: Color(argb: 0x66FFFFFF)
    )

    static let night = GlassTokens(
        tint: Color(argb: 0x24FFFFFF),
        tintFallback: Color(argb: 0x40FFFFFF),
        highlight: Color(argb: 0x24FFFFFF),
        rimLight: Color(argb: 0x80FFFFFF),
        rimDark: Color(argb: 0x14FFFFFF),
        shadow: Color(argb: 0x66000000),
        innerShade: Color(argb: 0x33000000),
        edgeDark: Color(argb: 0x4D000000),
        ambient: Color(argb: 0x4DFFFFFF)
    )
}

struct WallpaperTokens {
    var top: Color
    var bottom: Color
    var blobA: Color
    var blobB: Color
    var blobC: Color

    static let day = WallpaperTokens(
        top: Color(argb: 0xFFE4E5E8),
        bottom: Color(argb: 0xFFE4E5E8),
        blobA: Color(argb: 0xFFE4E5E8),
        blobB: Color(argb: 0xFFE4E5E8),
        blobC: Color(argb: 0xFFE4E5E8)
    )

    static let night = WallpaperTokens(
        top: Color(argb: 0xFF2C2D31),
        bottom: Color(argb: 0xFF2C2D31),
        blobA: Color(argb: 0xFF2C2D31),
        blobB: Color(argb: 0xFF2C2D31),
        blobC: Color(argb: 0xFF2C2D31)
    )
}

struct IconTokens {
    var glyph: Color
    var glyphShadow: Color
    var tileTint: Color
    var label: Color
    var labelShadow: Color

    static let day = IconTokens(
        glyph: Color(argb: 0xF5FFFFFF),
        glyphShadow: Color(argb: 0x33203040),
        tileTint: Color(argb: 0x14FFFFFF),
        label: Color(argb: 0xFF2B2F38),
        labelShadow: Color(argb: 0x00000000)
    )

    static let night = IconTokens(
        glyph: Color(argb: 0xF2FFFFFF),
        glyphShadow: Color(argb: 0x66000000),
        tileTint: Color(argb: 0x12FFFFFF),
        label: Color(argb: 0xFFFFFFFF),
        labelShadow: Color(argb: 0x66000000)
    )
}

struct PageDotTokens {
    var active: Color
    var inactive: Color

    static let day = PageDotTokens(active: Color(argb: 0xF2FFFFFF), inactive: Color(argb: 0x73FFFFFF))
    static let night = PageDotTokens(active: Color(argb: 0xF2FFFFFF), inactive: Color(argb: 0x66FFFFFF))
}

struct FolderTokens {
    var scrim: Color
    var panelFill: Color
    var title: Color
    var cursor: Color
    var miniTile: Color

    static let day = FolderTokens(
        scrim: Color(argb: 0x40000000),
        panelFill: Color(argb: 0x59FFFFFF),
        title: Color(argb: 0xFF2B2F38),
        cursor: Color(argb: 0xFF2B2F38),
        miniTile: Color(argb: 0x2E5A6C8A)
    )

    static let night = FolderTokens(
        scrim: Color(argb: 0x80000000),
        panelFill: Color(argb: 0x331B2540),
        title: Color(argb: 0xFFFFFFFF),
        cursor: Color(argb: 0xFFFFFFFF),
        miniTile: Color(argb: 0x1FFFFFFF)
    )
}

struct WidgetTokens {
    var clockText: Color
    var ringGreen: Color
    var ringRed: Color
    var ringTrack: Color

    static let day = WidgetTokens(
        clockText: Color(argb: 0xD9505763),
        ringGreen: Color(argb: 0xFF34C759),
        ringRed: Color(argb: 0xFFFF3B30),
        ringTrack: Color(argb: 0x26000000)
    )

    static let night = WidgetTokens(
        clockText: Color(argb: 0xE6FFFFFF),
        ringGreen: Color(argb: 0xFF30D158),
        ringRed: Color(argb: 0xFFFF453A),
        ringTrack: Color(argb: 0x40FFFFFF)
    )
}
