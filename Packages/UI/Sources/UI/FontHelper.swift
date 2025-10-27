import UIKit
import CoreText

public enum FontHelper {
    public static func registerFontsIfNeeded() {
        
        let fontNames = ["Alegreya", "Inter"]

        fontNames.forEach { name in
            registerFont(named: name)
        }
    }

    private static func registerFont(named name: String) {

        guard let url = Bundle.module.url(forResource: name, withExtension: "ttf"),
              let dataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(dataProvider) else {
            print("❌ Failed to load font: \(name)")
            return
        }

        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("❌ Failed to register font \(name): \(error?.takeUnretainedValue().localizedDescription ?? "Unknown error")")
        }
    }
}

