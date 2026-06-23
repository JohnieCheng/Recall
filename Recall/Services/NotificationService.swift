import Foundation
import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    override init() { super.init(); center.delegate = self }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func post(_ word: Word, speak: Bool) {
        let body = "\(word.phonetic)  \(word.partOfSpeech) \(word.definition)\n\(word.collocation)"
        let b = body.replacingOccurrences(of: "\"", with: "\\\"")
        let t = Process()
        t.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        t.arguments = ["-e", "display notification \"\(b)\" with title \"\(word.word)\" sound name \"default\""]
        try? t.run()

        if speak {
            SpeechEngine.shared.speak(
                text: "\(word.word). \(word.definition). \(word.collocation)"
            )
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
