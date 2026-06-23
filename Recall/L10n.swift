import Foundation

/// 双语支持，默认英文，可在设置里切换
enum L10n {
    private static let langKey = "appLanguage"

    static var currentLanguage: String {
        get { UserDefaults.standard.string(forKey: langKey) ?? "en" }
        set {
            UserDefaults.standard.set(newValue, forKey: langKey)
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }

    private static var isChinese: Bool {
        currentLanguage == "zh"
    }

    // MARK: - App
    static var appName: String { "Recall" }

    // MARK: - Menu Bar
    static var menuEmpty: String { isChinese ? "词库为空" : "No words" }
    static var menuNext: String { isChinese ? "下一个单词" : "Next Word" }
    static var menuSpeak: String { isChinese ? "朗读" : "Speak" }
    static var menuSettings: String { isChinese ? "设置" : "Settings" }
    static var menuHistory: String { isChinese ? "历史记录" : "History" }
    static var menuQuit: String { isChinese ? "退出" : "Quit" }

    // MARK: - Settings: 操作
    static var settingsPushNow: String { isChinese ? "立即推送一个单词" : "Push Now" }
    static var settingsStartTimer: String { isChinese ? "启动定时推送" : "Start Timer" }
    static var settingsPauseTimer: String { isChinese ? "暂停定时推送" : "Pause Timer" }
    static var settingsSectionAction: String { isChinese ? "操作" : "Actions" }

    // MARK: - Settings: 通知
    static var settingsInterval: String { isChinese ? "间隔时间" : "Interval" }
    static var settingsSectionNotification: String { isChinese ? "通知设置" : "Notifications" }

    // MARK: - Settings: 朗读
    static var settingsSpeak: String { isChinese ? "朗读单词" : "Speak Word" }
    static var settingsSectionSpeak: String { isChinese ? "朗读设置" : "Speech" }

    // MARK: - Settings: 状态
    static var settingsCurrentWord: String { isChinese ? "当前单词" : "Current Word" }
    static var settingsLearnedCount: String { isChinese ? "已学单词" : "Learned" }
    static var settingsSectionStatus: String { isChinese ? "学习状态" : "Progress" }

    // MARK: - Settings: 词库管理
    static var settingsImportCSV: String { isChinese ? "导入 CSV 文件" : "Import CSV" }
    static var settingsImporting: String { isChinese ? "导入中..." : "Importing..." }
    static var settingsRename: String { isChinese ? "重命名" : "Rename" }
    static var settingsDelete: String { isChinese ? "删除" : "Delete" }
    static var settingsWordCount: String { isChinese ? "词" : "words" }
    static var settingsRenameTitle: String { isChinese ? "重命名词库" : "Rename Library" }
    static var settingsRenamePlaceholder: String { isChinese ? "词库名称" : "Library Name" }
    static var settingsCancel: String { isChinese ? "取消" : "Cancel" }
    static var settingsConfirm: String { isChinese ? "确定" : "OK" }
    static var settingsSectionLibrary: String { isChinese ? "词库管理" : "Libraries" }

    // MARK: - Import
    static var importMessage: String { isChinese ? "选择词库 CSV 文件" : "Select CSV word list" }
    static var importPrompt: String { isChinese ? "导入" : "Import" }
    static var importFailed: String { isChinese ? "导入失败" : "Import Failed" }
    static var importOK: String { isChinese ? "确定" : "OK" }

    // MARK: - Language
    static var languageSection: String { isChinese ? "语言" : "Language" }
    static var languageLabel: String { isChinese ? "语言" : "Language" }
    static var languageEN: String { "English" }
    static var languageZH: String { "中文" }

    // MARK: - History
    static var historyTitle: String { isChinese ? "学习记录" : "History" }
    static var historyTotal: String { isChinese ? "共" : "" }
    static var historyCount: String { isChinese ? "个单词" : "words" }
    static var historyEmpty: String { isChinese ? "还没有学习记录" : "No records yet" }

    static let intervals: [(String, TimeInterval)] = [
        ("1 分钟" + (isChinese ? "" : " min"), 60),
        ("3 分钟" + (isChinese ? "" : " min"), 180),
        ("5 分钟" + (isChinese ? "" : " min"), 300),
        ("10 分钟" + (isChinese ? "" : " min"), 600),
        ("30 分钟" + (isChinese ? "" : " min"), 1800),
        ("1 小时" + (isChinese ? "" : " hour"), 3600),
        ("2 小时" + (isChinese ? "" : " hours"), 7200),
        ("4 小时" + (isChinese ? "" : " hours"), 14400),
        ("8 小时" + (isChinese ? "" : " hours"), 28800),
    ]
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("RecallLanguageDidChange")
}
