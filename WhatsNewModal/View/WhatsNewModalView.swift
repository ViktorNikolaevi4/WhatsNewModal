
import SwiftUI
import MarkdownUI

struct WhatsNewModalView: View {
    var markdownFileName: String
    var title: String
    var preferH1Title: Bool
    var icon: NSImage?
    var heroAssetName: String?
    var showTopTitle: Bool
    var drawBackground: Bool
    var onContinue: (() -> Void)?

    init(
        markdownFileName: String = "WhatsNew",
        title: String = "What's new",
        preferH1Title: Bool = true,
        icon: NSImage? = NSApp.applicationIconImage,
        heroAssetName: String? = nil,
        showTopTitle: Bool = true,
        drawBackground: Bool = true,
        onContinue: (() -> Void)? = nil
    ) {
        self.markdownFileName = markdownFileName
        self.title = title
        self.preferH1Title = preferH1Title
        self.icon = icon
        self.heroAssetName = heroAssetName
        self.showTopTitle = showTopTitle
        self.drawBackground = drawBackground
        self.onContinue = onContinue
    }

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
            if let hero = heroAssetName {
                Image(hero)
                    .resizable().interpolation(.high)
                    .scaledToFit()
                    .frame(maxWidth: 560, maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.separator, lineWidth: 1))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                    .padding(.top, 8)
            }
            if showTopTitle {
                Text(runtimeTitle ?? title)
                    .font(.title).bold()
                    .padding(.top, 4)
            }

            ScrollView {
                Markdown(markdownText)
                    .frame(maxWidth: 560, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(.clear)
            }
            .frame(maxHeight: 400)
            Button("Continue") {
                if let onContinue { onContinue() }
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(PrimaryCapsuleButtonStyle())
            .padding(.bottom, 4)
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 520)
     //   .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(drawBackground ? Color(nsColor: .windowBackgroundColor) : .clear)
        .accessibilityAddTraits(.isModal)
        .onAppear {
            let raw = MarkdownLoader.load(named: markdownFileName)
            if preferH1Title && showTopTitle {
                let parts = MarkdownLoader.extractH1AndBody(from: raw)
                runtimeTitle = parts.title ?? runtimeTitle
                markdownText = parts.body
            } else {
                markdownText = raw
            }
        }
    }
}
