import AppKit
import SwiftUI

@main
struct WhatsNewModalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        BorderlessCardWindow.shared.show {
            WhatsNewModalView(
                markdownFileName: "release-notes",
                preferH1Title: true,
                icon: NSImage(named: "рисунок"),
                showTopTitle: false,
                drawBackground: false
            ) {
                BorderlessCardWindow.shared.close()
                NSApp.terminate(nil)
            }
        }
    }
}
