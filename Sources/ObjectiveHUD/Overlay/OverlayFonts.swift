import SwiftUI

enum OverlayFont {
    private static let fontName = "Michroma-Regular"

    static func icon() -> Font {
        .custom(fontName, size: 13)
    }

    static func sectionLabel() -> Font {
        .custom(fontName, size: 15)
    }

    static func objectiveTitle() -> Font {
        .custom(fontName, size: 12)
    }

    static func objectiveSuffix() -> Font {
        .custom(fontName, size: 14)
    }
}
