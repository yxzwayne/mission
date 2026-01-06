import Foundation
import CoreText

@MainActor
enum AppFontRegistry {
    private static var didRegister = false

    static func registerCustomFonts() {
        guard !didRegister else { return }
        didRegister = true
        registerFont(named: "Michroma-Regular", withExtension: "ttf")
    }

    private static func registerFont(named name: String, withExtension ext: String) {
        guard let fontURL = Bundle.module.url(forResource: name, withExtension: ext) else {
            assertionFailure("Missing font resource: \\(name).\\(ext)")
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
            if let cfError = error?.takeRetainedValue(),
               CFErrorGetCode(cfError) != CTFontManagerError.alreadyRegistered.rawValue {
                assertionFailure("Failed to register font: \\(cfError)")
            }
        }
    }
}
