
import SwiftUI
import AppKit

final class KeyPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class BorderlessCardWindow {
    static let shared = BorderlessCardWindow()
    private var window: KeyPanel?

    func show<Content: View>(@ViewBuilder content: () -> Content) {
        guard window == nil else { return }

        let card = AnyView(
            content()
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .shadow(color: .black.opacity(0.18), radius: 30, y: 12)
                )
                .padding(24)
                .background(Color.clear)
        )

        let host = NSHostingView(rootView: card)
        host.wantsLayer = true
        host.layer?.backgroundColor = NSColor.clear.cgColor

        let win = KeyPanel(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 720),
            styleMask: [.borderless],
            backing: .buffered, defer: false
        )
        win.isOpaque = false
        win.backgroundColor = .clear
        win.level = .modalPanel
        win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        win.isMovableByWindowBackground = true
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
        win.hasShadow = false
        win.isReleasedWhenClosed = true
        win.contentView = host

        NSApp.activate(ignoringOtherApps: true)
        win.center()
        win.makeKeyAndOrderFront(nil)
        self.window = win
    }

    func close() {
        window?.orderOut(nil)
        window = nil
    }
}
