// DragCompatibility shim: allow using `.draggable(NSItemProvider)` by routing to `.onDrag { ... }`
// This fixes: "Instance method 'draggable' requires that 'NSItemProvider' conform to 'Transferable'"
// by providing an overload that accepts NSItemProvider and forwards to SwiftUI's onDrag API.

import SwiftUI
#if os(macOS)
import AppKit // for NSItemProvider
#endif

extension View {
    /// Enables drag using an NSItemProvider by forwarding to SwiftUI's onDrag.
    /// This mirrors the common `.draggable(_, preview:)` surface for Transferable,
    /// but works with NSItemProvider-based drag and drop on macOS.
    func draggable(_ provider: NSItemProvider) -> some View {
        onDrag { provider }
    }

    /// Enables drag with a preview using an NSItemProvider by forwarding to onDrag(_:preview:).
    func draggable<Preview: View>(_ provider: NSItemProvider, preview: @escaping () -> Preview) -> some View {
        onDrag({ provider }, preview: preview)
    }
}
