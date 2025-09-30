
import Foundation
import SwiftUI

struct RootView: View {
    @State private var showWhatsNew = true

    var body: some View {
        ZStack {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .disabled(showWhatsNew)
                .blur(radius: showWhatsNew ? 0 : 0)  // можно добавить блюр, если захочешь ?
            if showWhatsNew {
                WhatsNewModalView(
                    markdownFileName: "release-notes",
                    preferH1Title: true,
                    onContinue: { showWhatsNew = false }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showWhatsNew)
    }
}
