import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var manager: WordManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.historyTitle)
                    .font(.headline)
                Spacer()
                Text("\(L10n.historyTotal) \(manager.history.count) \(L10n.historyCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            if manager.history.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(L10n.historyEmpty)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(manager.history) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.word)
                                .font(.headline)
                            Text("\(entry.phonetic)  \(entry.definition)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(entry.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(width: 360, height: 400)
    }
}
