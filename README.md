# Recall

A bilingual vocabulary learning app in your macOS menu bar. Scheduled push notifications, text-to-speech, and custom CSV word libraries.

> [中文版](README.zh.md)

## Requirements

- macOS 14.0+
- Development / testing: macOS 26.5.1

## Features

- **Menu bar display** — current word shown in the menu bar, no Dock icon
- **Scheduled push** — configurable interval (1min ~ 8h) with system notification
- **Speech** — English (Karen🇦🇺) + Chinese (system voice), language-aware chunking, rapid re-speak interruption
- **Multi-library management** — import CSV files, name, enable/disable, delete
- **Learning stats** — word count + history list
- **Bilingual** — Chinese / English, switchable in Settings

## Project Structure

```
Recall/
├── Recall.xcodeproj
├── Recall/
│   ├── RecallApp.swift           # @main entry
│   ├── RecallAppDelegate.swift   # NSApplicationDelegate + NSWindow management
│   ├── L10n.swift                # Bilingual string constants
│   ├── Models/
│   │   ├── Word.swift            # Word model
│   │   └── CustomLibrary.swift   # Custom library model (Codable)
│   ├── Services/
│   │   ├── WordManager.swift     # Core: library CRUD, backlog, history, scheduling
│   │   ├── WordImporter.swift    # CSV parser (supports 5-col legacy & 6-col new)
│   │   ├── NotificationService.swift # System notifications via osascript
│   │   └── SpeechEngine.swift    # Speech engine (say + LanguageSplitter + interruption)
│   ├── Views/
│   │   ├── RecallMenuView.swift  # Menu bar popover
│   │   ├── SettingsView.swift    # Settings panel
│   │   └── HistoryView.swift     # Learning history
│   └── 词库模版.csv
├── Tests/
│   └── RecallTests/              # 25 unit tests
├── README.md
├── README.zh.md
└── .gitignore
```

## Architecture

```
RecallApp (@main)
  ├── L10n (bilingual constants)
  ├── RecallAppDelegate (NSWindow management)
  ├── RecallMenuView (menu bar UI)
  │     ├── WordManager (@MainActor ObservableObject)
  │     └── SpeechEngine (singleton)
  ├── SettingsView
  │     ├── WordManager
  │     ├── WordImporter (CSV import)
  │     └── L10n (language toggling)
  ├── HistoryView
  └── NotificationService
        └── SpeechEngine (speech trigger)
```

## CSV Template

6-column format (5-column legacy also supported):

```csv
word,phonetic,partOfSpeech,definition,enCollocation,zhCollocation
quantify,/ˈkwɒntɪfaɪ/,v.,quantify,quantify the impact,量化影响
```

## Build & Run

```bash
open -a Xcode Recall.xcodeproj
```

`cmd+R` to run. Command line:

```bash
xcodebuild -project Recall.xcodeproj -scheme Recall -configuration Release build
```

## Run Tests

```bash
swift test
```

25 tests across 4 suites — all pass.

## Technical Details

- **LSUIElement = YES** — pure menu bar app, no Dock icon
- **App Sandbox = NO** — required for `/usr/bin/say` and `osascript`
- **Language-aware chunking** — `LanguageSplitter` splits text at CJK boundaries, speaking each chunk separately. This works around a `say` bug where trailing CJK characters are silently dropped after English text
- **Interruption** — generation counter: new speech increments the counter, old loop checks and exits immediately
- **Notifications** — uses `osascript display notification` to work with ad-hoc code signing
- **Bilingual** — `L10n` enum reads language preference from UserDefaults; language change broadcasts via `NotificationCenter`, `WordManager.languageVersion` triggers SwiftUI view refresh via `.id()`

## License

MIT
