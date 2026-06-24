@testable import RecallCore
import Testing

struct LanguageSplitterTests {

    @Test func splitsEnglishAndChinese() {
        let text = "quantify. 量化定量."
        let parts = LanguageSplitter.split(text)
        #expect(parts == ["quantify.", "量化定量."])
    }

    @Test func splitsChineseFollowedByEnglish() {
        let text = "量化定量. quantify the impact"
        let parts = LanguageSplitter.split(text)
        #expect(parts == ["量化定量.", "quantify the impact"])
    }

    @Test func handlesFullFormat() {
        let text = "quantify. 量化定量. quantify the impact 量化影响"
        let parts = LanguageSplitter.split(text)
        #expect(parts.count == 4)
        #expect(parts[0] == "quantify.")
        #expect(parts[1] == "量化定量.")
        #expect(parts[2] == "quantify the impact")
        #expect(parts[3] == "量化影响")
    }

    @Test func pureEnglishReturnsSingleChunk() {
        let text = "quantify"
        let parts = LanguageSplitter.split(text)
        #expect(parts == ["quantify"])
    }

    @Test func pureChineseReturnsSingleChunk() {
        let text = "量化定量"
        let parts = LanguageSplitter.split(text)
        #expect(parts == ["量化定量"])
    }

    @Test func handlesEmptyText() {
        let parts = LanguageSplitter.split("")
        #expect(parts.isEmpty)
    }

    @Test func ignoresPunctuationBoundaries() {
        let text = "impact. 量化影响"
        let parts = LanguageSplitter.split(text)
        #expect(parts.count == 2)
        #expect(parts[0] == "impact.")
        #expect(parts[1] == "量化影响")
    }
}
