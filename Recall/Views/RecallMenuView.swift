import SwiftUI

struct RecallMenuView: View {
    let delegate: RecallAppDelegate
    @EnvironmentObject var manager: WordManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let word = manager.currentWord {
                wordInfo(word)

                Divider()

                Button(L10n.menuNext) { manager.nextWord() }
                Button(L10n.menuSpeak) {
                    SpeechEngine.shared.speak(
                        text: "\(word.word). \(word.definition). \(word.collocation)"
                    )
                }
            } else {
                Text(L10n.menuEmpty)
            }

            Divider()

            Button(L10n.menuSettings) { delegate.showSettingsWindow(manager: manager) }
            Button(L10n.menuHistory) { delegate.showHistoryWindow(manager: manager) }

            Divider()

            Button(L10n.menuQuit) { NSApplication.shared.terminate(nil) }
        }
        .padding(8)
        .id(manager.languageVersion)
    }

    @ViewBuilder
    private func wordInfo(_ word: Word) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(word.word)
                .font(.title2)
                .fontWeight(.bold)
            Text("\(word.phonetic)  \(word.partOfSpeech) \(word.definition)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(word.collocation)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
    }
}
