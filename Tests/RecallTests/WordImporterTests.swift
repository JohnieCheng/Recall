@testable import RecallCore
import Testing
import Foundation

struct WordImporterTests {

    // MARK: - 6 列新版格式

    @Test func parsesSixColumnFormat() throws {
        let csv = """
        word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation
        quantify,/ˈkwɒntɪfaɪ/,v.,量化,quantify the impact,量化影响
        abolish,/əˈbɒlɪʃ/,v.,废除,abolish slavery,废除奴隶制
        """
        let words = try WordImporter.parseCSV(content: csv)
        #expect(words.count == 2)

        let first = words.first!
        #expect(first.word == "quantify")
        #expect(first.phonetic == "/ˈkwɒntɪfaɪ/")
        #expect(first.partOfSpeech == "v.")
        #expect(first.definition == "量化")
        #expect(first.enCollocation == "quantify the impact")
        #expect(first.zhCollocation == "量化影响")
    }

    @Test func sixColumnCollocationIsJoined() throws {
        let csv = """
        word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation
        quantify,/ˈkwɒntɪfaɪ/,v.,量化,quantify the impact,量化影响
        """
        let words = try WordImporter.parseCSV(content: csv)
        let w = words.first!
        #expect(w.collocation == "quantify the impact 量化影响")
    }

    // MARK: - 5 列旧版格式

    @Test func parsesFiveColumnFormat() throws {
        let csv = """
        word,phonetic,partOfSpeech,definition,collocation
        hierarchy,/ˈhaɪərɑːki/,n.,等级层次,social hierarchy 社会等级
        """
        let words = try WordImporter.parseCSV(content: csv)
        #expect(words.count == 1)
        let w = words.first!
        #expect(w.word == "hierarchy")
        #expect(w.definition == "等级层次")
        #expect(w.collocation == "social hierarchy 社会等级")
    }

    // MARK: - 验证 & 错误

    @Test func rejectsMissingWordHeader() {
        let csv = """
        name,definition
        test,hello
        """
        #expect(throws: WordImporter.ImportError.invalidHeader) {
            try WordImporter.parseCSV(content: csv)
        }
    }

    @Test func rejectsMissingDefinitionHeader() {
        let csv = """
        word,phonetic
        test,/tɛst/
        """
        #expect(throws: WordImporter.ImportError.invalidHeader) {
            try WordImporter.parseCSV(content: csv)
        }
    }

    @Test func rejectsEmptyFile() {
        #expect(throws: WordImporter.ImportError.emptyFile) {
            try WordImporter.parseCSV(content: "")
        }
    }

    @Test func skipsEmptyLines() throws {
        let csv = """
        word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation

        quantify,/ˈkwɒntɪfaɪ/,v.,量化,quantify the impact,量化影响

        abolish,/əˈbɒlɪʃ/,v.,废除,abolish slavery,废除奴隶制

        """
        let words = try WordImporter.parseCSV(content: csv)
        #expect(words.count == 2)
    }

    // MARK: - CSV 转义

    @Test func handlesQuotedFields() throws {
        let csv = """
        word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation
        test,/tɛst/,v.,"test, verify",run a test,运行测试
        """
        let words = try WordImporter.parseCSV(content: csv)
        #expect(words.count == 1)
        #expect(words.first!.enCollocation == "run a test")
    }

    @Test func trimsColumns() throws {
        let csv = """
        word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation
          abolish  ,/əˈbɒlɪʃ/ , v. , 废除 , abolish slavery , 废除奴隶制
        """
        let words = try WordImporter.parseCSV(content: csv)
        #expect(words.first?.word == "abolish")
        #expect(words.first?.partOfSpeech == "v.")
    }
}
