import Foundation

struct CustomLibrary: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var enabled: Bool
    var words: [Word]

    init(id: UUID = UUID(), name: String, enabled: Bool = true, words: [Word]) {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.words = words
    }

    static func == (lhs: CustomLibrary, rhs: CustomLibrary) -> Bool { lhs.id == rhs.id }
}
