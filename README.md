# Recall

macOS 菜单栏背单词应用，定时推送 + 朗读 + 自定义词库。中英文双语支持。

## 系统要求

- macOS 14.0+
- 开发/测试环境：macOS 26.5.1

## 功能

- **菜单栏显示** — 当前单词挂在右上角，不占 Dock
- **定时推送** — 间隔可配（1min ~ 8h），弹出系统通知
- **朗读** — 英文 Karen / 中文系统音色，按语言边界拆分朗读，快速连点打断
- **多词库管理** — CSV 导入，可命名、启用/禁用、删除
- **学习统计** — 已学计数 + 历史记录
- **双语** — 中文 / English，设置里一键切换

## 项目结构

```
Recall/
├── Recall.xcodeproj
├── Recall/
│   ├── RecallApp.swift           # @main 入口
│   ├── RecallAppDelegate.swift   # NSApplicationDelegate + NSWindow 管理
│   ├── L10n.swift                # 双语字符串常量
│   ├── Models/
│   │   ├── Word.swift            # 单词模型
│   │   └── CustomLibrary.swift   # 自定义词库模型（Codable）
│   ├── Services/
│   │   ├── WordManager.swift     # 核心调度（词库 CRUD / 待背队列 / 历史）
│   │   ├── WordImporter.swift    # CSV 解析（兼容 5 列旧版 / 6 列新版）
│   │   ├── NotificationService.swift # 系统通知（osascript）
│   │   └── SpeechEngine.swift    # 语音引擎（say + LanguageSplitter + 打断）
│   ├── Views/
│   │   ├── RecallMenuView.swift  # 菜单栏弹窗
│   │   ├── SettingsView.swift    # 设置面板（操作 / 通知 / 朗读 / 语言 / 状态 / 词库）
│   │   └── HistoryView.swift     # 学习记录
│   └── 词库模版.csv
├── README.md
└── .gitignore
```

## 架构

```
RecallApp (@main)
  ├── L10n (双语常量)
  ├── RecallAppDelegate (NSWindow 管理)
  ├── RecallMenuView (菜单栏 UI)
  │     ├── WordManager (@MainActor ObservableObject)
  │     └── SpeechEngine (singleton)
  ├── SettingsView (设置面板)
  │     ├── WordManager
  │     ├── WordImporter (CSV 导入)
  │     └── L10n (语言切换)
  ├── HistoryView (学习记录)
  └── NotificationService (系统通知)
        └── SpeechEngine (朗读触发)
```

- **SpeechEngineProtocol** — 语音引擎抽象，方便替换实现或 mock
- **L10n** — 中英文字符串统一管理，UserDefaults 持久化语言偏好
- 语言切换通过 `NotificationCenter` → `WordManager.languageVersion` → SwiftUI `.id()` 立即刷新

## 词库模版

6 列格式（兼容旧版 5 列）：

```csv
word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation
quantify,/ˈkwɒntɪfaɪ/,v.,量化,quantify the impact,量化影响
```

## 构建 & 运行

```bash
open -a Xcode Recall.xcodeproj
```

`cmd+R` 运行。命令行构建：

```bash
xcodebuild -project Recall.xcodeproj -scheme Recall -configuration Release build
```

## 技术要点

- **LSUIElement = YES** — 无 Dock 图标，纯菜单栏 App
- **App Sandbox = NO** — 调用 `/usr/bin/say` 和 `osascript` 需要
- **中英文拆分** — `LanguageSplitter` 按 Unicode 边界拆成纯英文 / 纯中文 chunk，分别用 `say -v Karen` 和系统默认音色朗读，解决 `say` 中英混合时吞掉尾部中文的 bug
- **打断机制** — 代际标记（generation counter）：新朗读递增代际，旧循环检测到变化后退出
- **通知** — `osascript display notification`，兼容 ad-hoc 签名
- **双语** — `L10n` 枚举根据 UserDefaults 中的语言偏好切换中/英；切换时通过 `NotificationCenter` 广播，`WordManager.languageVersion` 变化触发所有 SwiftUI 视图刷新

## 许可证

MIT
