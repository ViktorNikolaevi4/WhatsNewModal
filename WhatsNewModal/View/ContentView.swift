
import SwiftUI
import MarkdownUI

struct WhatsNewModalView: View {
    @Environment(\.dismiss) private var dismiss
    var markdownFileName: String = "WhatsNew"
    var title: String = "Что нового"
    var preferH1Title: Bool = true
    var icon: NSImage? = NSApp.applicationIconImage

    var onContinue: (() -> Void)? = nil

    @State private var markdownText: String = ""
    @State private var runtimeTitle: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            if let icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(radius: 8)
                    .padding(.top, 8)
            }
            Text(runtimeTitle ?? title)
                .font(.title).bold()
                .padding(.top, 4)
            ScrollView {
                Markdown(markdownText)
                //    .markdownTheme(.gitHub)
                    .frame(maxWidth: 560, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(.clear)
            }
            .frame(maxHeight: 360)
            Button("Continue") {
                if let onContinue { onContinue()
                } else {
                    dismiss()
                }
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(PrimaryCapsuleButtonStyle())
            .padding(.bottom, 4)
        }
        .padding(24)
        .frame(minWidth: 640, minHeight: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .windowBackgroundColor))
        .accessibilityAddTraits(.isModal)
        .onAppear {
            let raw = MarkdownLoader.load(named: markdownFileName)
            if preferH1Title {
                let parts = MarkdownLoader.extractH1AndBody(from: raw)
                runtimeTitle = parts.title ?? runtimeTitle
                markdownText = parts.body
            } else {
                markdownText = raw
            }
        }
    }
}
// Заглушка основного контента
struct ContentView: View {
    var body: some View {
        Text("Main app UI goes here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
