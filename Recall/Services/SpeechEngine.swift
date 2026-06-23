import Foundation

protocol SpeechEngineProtocol: AnyObject {
    func speak(text: String)
}

final class SpeechEngine: SpeechEngineProtocol {
    static let shared = SpeechEngine()

    private var currentTask: Process?
    private var generation: Int = 0
    private let queue = DispatchQueue(label: "com.johnie.recall.speech")

    private init() {}

    func speak(text: String) {
        // 打断上一次朗读
        currentTask?.terminate()
        generation += 1
        let gen = generation

        let chunks = LanguageSplitter.split(text)

        queue.async { [weak self] in
            guard let self = self else { return }
            for chunk in chunks {
                if self.generation != gen { return } // 被新请求打断

                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/bin/say")

                let isZh = chunk.unicodeScalars.contains {
                    $0.value >= 0x4E00 && $0.value <= 0x9FFF
                }
                task.arguments = isZh ? [chunk] : ["-v", "Karen", chunk]

                self.currentTask = task
                DispatchQueue.main.sync { try? task.run() }
                task.waitUntilExit()
            }
            if self.generation == gen {
                self.currentTask = nil
            }
        }
    }
}

// MARK: - Language Splitter

private enum LanguageSplitter {
    static func split(_ text: String) -> [String] {
        let delimiter = "\u{001E}"
        var s = text
        // 英文 → 中文边界
        s = s.replacingOccurrences(
            of: "([a-zA-Z])([^a-zA-Z\\u4e00-\\u9fff]*)([\\u4e00-\\u9fff])",
            with: "$1$2\(delimiter)$3",
            options: .regularExpression
        )
        // 中文 → 英文边界
        s = s.replacingOccurrences(
            of: "([\\u4e00-\\u9fff])([^a-zA-Z\\u4e00-\\u9fff]*)([a-zA-Z])",
            with: "$1$2\(delimiter)$3",
            options: .regularExpression
        )
        return s.components(separatedBy: delimiter)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
