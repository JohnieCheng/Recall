import Foundation
import UniformTypeIdentifiers

struct WordImporter {

    /// 解析 CSV 文件内容，返回单词列表
    static func parseCSV(url: URL) throws -> [Word] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return try parseCSV(content: content)
    }

    /// 解析 CSV 字符串，返回单词列表
    /// 格式: word,phonetic,partOfSpeech,definition,collocation
    static func parseCSV(content: String) throws -> [Word] {
        var lines = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // 去掉 BOM 头
        if let first = lines.first, first.hasPrefix("\u{FEFF}") {
            lines[0] = String(first.dropFirst())
        }

        guard lines.count >= 2 else {
            throw ImportError.emptyFile
        }

        // 验证表头
        let header = lines.removeFirst()
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        guard header.contains("word"),
              header.contains("definition") else {
            throw ImportError.invalidHeader
        }

        let wordIdx = header.firstIndex(of: "word") ?? 0
        let phoneticIdx = header.firstIndex(of: "phonetic")
        let posIdx = header.firstIndex(of: "partofspeech")
        let defIdx = header.firstIndex(of: "definition") ?? 0
        let collIdx = header.firstIndex(of: "collocation")
        let enCollIdx = header.firstIndex(of: "encollocation")
        let zhCollIdx = header.firstIndex(of: "zhcollocation")

        var words: [Word] = []

        for (_, line) in lines.enumerated() {
            let cols = parseCSVLine(line)
            guard cols.count > max(wordIdx, defIdx) else { continue }

            let word = cols[wordIdx].trimmingCharacters(in: .whitespaces)
            guard !word.isEmpty else { continue }

            let phonetic = phoneticIdx.map { cols[safe: $0]?.trimmingCharacters(in: .whitespaces) ?? "" } ?? ""
            let partOfSpeech = posIdx.map { cols[safe: $0]?.trimmingCharacters(in: .whitespaces) ?? "" } ?? ""
            let definition = cols[defIdx].trimmingCharacters(in: .whitespaces)

            // 支持新旧两种格式
            if let eIdx = enCollIdx, let zIdx = zhCollIdx {
                let enColl = cols[safe: eIdx]?.trimmingCharacters(in: .whitespaces) ?? ""
                let zhColl = cols[safe: zIdx]?.trimmingCharacters(in: .whitespaces) ?? ""
                words.append(Word(word: word, phonetic: phonetic, partOfSpeech: partOfSpeech, definition: definition, enCollocation: enColl, zhCollocation: zhColl))
            } else {
                let collocation = collIdx.map { cols[safe: $0]?.trimmingCharacters(in: .whitespaces) ?? "" } ?? ""
                words.append(Word(word: word, phonetic: phonetic, partOfSpeech: partOfSpeech, definition: definition, collocation: collocation))
            }
        }

        if words.isEmpty {
            throw ImportError.noWordsFound
        }

        return words
    }

    /// 手动解析带引号的 CSV 行（处理逗号、引号转义）
    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = String()
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = String()
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }

    enum ImportError: Error, LocalizedError {
        case emptyFile
        case invalidHeader
        case noWordsFound

        var errorDescription: String? {
            switch self {
            case .emptyFile: return "文件为空"
            case .invalidHeader: return "CSV 表头缺少 word 或 definition 列"
            case .noWordsFound: return "未找到有效单词"
            }
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
