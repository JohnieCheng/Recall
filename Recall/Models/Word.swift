import Foundation

struct Word: Codable, Identifiable, Equatable {
    let id: UUID
    let word: String
    let phonetic: String
    let partOfSpeech: String
    let definition: String
    let collocation: String
    let enCollocation: String
    let zhCollocation: String

    init(word: String, phonetic: String, partOfSpeech: String, definition: String, collocation: String) {
        self.id = UUID()
        self.word = word
        self.phonetic = phonetic
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.collocation = collocation
        self.enCollocation = ""
        self.zhCollocation = ""
    }

    init(word: String, phonetic: String, partOfSpeech: String, definition: String, enCollocation: String, zhCollocation: String) {
        self.id = UUID()
        self.word = word
        self.phonetic = phonetic
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.enCollocation = enCollocation
        self.zhCollocation = zhCollocation
        self.collocation = "\(enCollocation) \(zhCollocation)"
    }
}
