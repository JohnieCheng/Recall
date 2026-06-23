import SwiftUI

@main
struct RecallApp: App {
    @NSApplicationDelegateAdaptor(RecallAppDelegate.self) var appDelegate
    @StateObject private var manager = WordManager.shared

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra {
            RecallMenuView(delegate: appDelegate)
                .environmentObject(manager)
        } label: {
            if let word = manager.currentWord {
                Text(word.word)
                    .font(.system(.body, design: .monospaced))
            } else {
                Label(L10n.appName, systemImage: "book.closed")
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
