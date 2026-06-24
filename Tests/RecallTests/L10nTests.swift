@testable import RecallCore
import Testing
import Foundation

struct L10nTests {

    @Test func defaultsToEnglish() {
        L10n.currentLanguage = "en"
        #expect(L10n.menuSettings == "Settings")
        #expect(L10n.settingsPushNow == "Push Now")
        #expect(L10n.historyTitle == "History")
        #expect(L10n.menuQuit == "Quit")
    }

    @Test func switchesToChinese() {
        L10n.currentLanguage = "zh"
        #expect(L10n.menuSettings == "设置")
        #expect(L10n.settingsPushNow == "立即推送一个单词")
        #expect(L10n.historyTitle == "学习记录")
        #expect(L10n.menuQuit == "退出")
    }

    @Test func languageLabelsAreFixed() {
        L10n.currentLanguage = "zh"
        #expect(L10n.languageEN == "English")
        #expect(L10n.languageZH == "中文")

        L10n.currentLanguage = "en"
        #expect(L10n.languageEN == "English")
        #expect(L10n.languageZH == "中文")
    }

    @Test func appNameIsAlwaysRecall() {
        L10n.currentLanguage = "en"
        #expect(L10n.appName == "Recall")

        L10n.currentLanguage = "zh"
        #expect(L10n.appName == "Recall")
    }

    @Test func roundTripLanguage() {
        L10n.currentLanguage = "zh"
        #expect(L10n.currentLanguage == "zh")

        L10n.currentLanguage = "en"
        #expect(L10n.currentLanguage == "en")
    }
}
