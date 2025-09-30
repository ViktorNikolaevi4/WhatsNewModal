import SwiftUI
import AppKit

struct RootView: View {
    @State private var showWhatsNew = true

    var body: some View {
        ZStack {
            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
            if showWhatsNew {
                WhatsNewModalView(
                    markdownFileName: "release-notes",
                    preferH1Title: true,
                    icon: NSImage(named: "рисунок")
                ) {
                    showWhatsNew = false
                    NSApp.keyWindow?.close() 
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showWhatsNew)
    }
}

