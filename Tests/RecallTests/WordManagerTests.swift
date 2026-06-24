@testable import RecallCore
import Testing
import Foundation

@MainActor
struct WordManagerTests {

    private let ud: UserDefaults
    private let sut: WordManager

    init() {
        ud = UserDefaults(suiteName: "com.recall.test.\(UUID().uuidString)")!
        sut = WordManager()
        sut.ud = ud
        sut.loadLibraries()
        sut.buildBacklog()
    }

    // MARK: - Persistence

    @Test func persistsAndLoadsLibraries() {
        let lib = CustomLibrary(name: "TestLib", words: [
            Word(word: "test", phonetic: "/tɛst/", partOfSpeech: "v.",
                 definition: "测试", collocation: "test it 测试它")
        ])
        sut.customLibraries = [lib]

        // 重新实例化模拟重启
        let sut2 = WordManager()
        sut2.ud = ud
        sut2.loadLibraries()
        #expect(sut2.customLibraries.count == 1)
        #expect(sut2.customLibraries.first?.name == "TestLib")
    }

    @Test func toggleLibraryEnabled() {
        let lib = CustomLibrary(name: "Words", words: [
            Word(word: "hello", phonetic: "", partOfSpeech: "",
                 definition: "", collocation: "")
        ])
        sut.customLibraries = [lib]
        #expect(sut.customLibraries.first?.enabled == true)

        sut.toggleLibrary(lib.id)
        #expect(sut.customLibraries.first?.enabled == false)

        sut.toggleLibrary(lib.id)
        #expect(sut.customLibraries.first?.enabled == true)
    }

    // MARK: - Backlog

    @Test func backlogContainsOnlyEnabledLibraries() {
        let libA = CustomLibrary(name: "A", enabled: true, words: [
            Word(word: "word1", phonetic: "", partOfSpeech: "", definition: "", collocation: "")
        ])
        let libB = CustomLibrary(name: "B", enabled: false, words: [
            Word(word: "word2", phonetic: "", partOfSpeech: "", definition: "", collocation: "")
        ])
        sut.customLibraries = [libA, libB]
        sut.buildBacklog()

        sut.pickRandom()
        #expect(sut.currentWord?.word == "word1")
    }

    @Test func backlogIsEmptyWhenNoEnabledLibraries() {
        let lib = CustomLibrary(name: "A", enabled: false, words: [
            Word(word: "only", phonetic: "", partOfSpeech: "", definition: "", collocation: "")
        ])
        sut.customLibraries = [lib]
        sut.buildBacklog()
        sut.pickRandom()
        #expect(sut.currentWord == nil)
    }
}
