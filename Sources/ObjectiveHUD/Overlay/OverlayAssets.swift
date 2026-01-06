import AppKit

enum OverlayAssets {
    static let missionTriangle: NSImage? = {
        guard let url = Bundle.module.url(forResource: "mission-triangle", withExtension: "png") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }()
}
