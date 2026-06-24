import Foundation
import Combine

@MainActor
class WordManager: ObservableObject {
    static let shared = WordManager()

    @Published var currentWord: Word?
    @Published var history: [HistoryEntry] = []
    @Published var learnedWords: Set<UUID> = []
    @Published var isRunning = false
    @Published var customLibraries: [CustomLibrary] = [] {
        didSet { saveLibraries() }
    }
    @Published var languageVersion = 0

    var enabledCustomWordCount: Int {
        customLibraries.filter(\.enabled).reduce(0) { $0 + $1.words.count }
    }

    var enabledCustomWords: [Word] {
        customLibraries.filter(\.enabled).flatMap(\.words)
    }

    private var timer: Timer?
    private var backlog: [Word] = []

    private let intervalKey = "notificationInterval"
    private let speakEnabledKey = "speakEnabled"
    private let librariesKey = "customLibraries"

    @Published var notificationInterval: TimeInterval = 3600 {
        didSet { UserDefaults.standard.set(notificationInterval, forKey: intervalKey) }
    }

    @Published var speakEnabled: Bool = true {
        didSet { UserDefaults.standard.set(speakEnabled, forKey: speakEnabledKey) }
    }

    init() {
        notificationInterval = UserDefaults.standard.double(forKey: intervalKey).nonZero ?? 3600
        speakEnabled = UserDefaults.standard.object(forKey: speakEnabledKey) as? Bool ?? true
        loadHistory()
        loadLibraries()
        buildBacklog()
        pickRandom()

        NotificationCenter.default.addObserver(
            forName: .languageDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.languageVersion += 1
            }
        }
    }

    var ud: UserDefaults = .standard

    // MARK: - Library Persistence

    func loadLibraries() {
        guard let data = ud.data(forKey: librariesKey),
              let libs = try? JSONDecoder().decode([CustomLibrary].self, from: data) else { return }
        customLibraries = libs
    }

    private func saveLibraries() {
        if let data = try? JSONEncoder().encode(customLibraries) {
            ud.set(data, forKey: librariesKey)
        }
    }

    // MARK: - Library Management

    func importWords(from url: URL) throws -> Int {
        let words = try WordImporter.parseCSV(url: url)
        let name = url.deletingPathExtension().lastPathComponent
        let lib = CustomLibrary(name: name, words: words)
        customLibraries.append(lib)
        buildBacklog()
        return words.count
    }

    func toggleLibrary(_ id: UUID) {
        guard let idx = customLibraries.firstIndex(where: { $0.id == id }) else { return }
        customLibraries[idx].enabled.toggle()
        buildBacklog()
    }

    func renameLibrary(_ id: UUID, to name: String) {
        guard let idx = customLibraries.firstIndex(where: { $0.id == id }) else { return }
        customLibraries[idx].name = name
        saveLibraries()
    }

    func deleteLibrary(_ id: UUID) {
        customLibraries.removeAll { $0.id == id }
        buildBacklog()
    }

    // MARK: - Word Selection

    func buildBacklog() {
        let all = enabledCustomWords.shuffled()
        let unlearned = all.filter { !learnedWords.contains($0.id) }
        let learned = all.filter { learnedWords.contains($0.id) }
        backlog = unlearned + learned
    }

    func pickRandom() {
        if backlog.isEmpty { buildBacklog() }
        guard !backlog.isEmpty else { return }
        currentWord = backlog.removeFirst()
    }

    func markLearned(_ word: Word) {
        learnedWords.insert(word.id)
        saveHistory()
    }

    func nextWord() {
        if let word = currentWord {
            markLearned(word)
        }
        pickRandom()
        pushCurrent()
    }

    // MARK: - Notifications

    func pushCurrent() {
        guard let word = currentWord else { return }
        NotificationService.shared.post(word, speak: speakEnabled)
        addToHistory(word)
    }

    // MARK: - Scheduling

    func startSchedule() {
        stopSchedule()
        isRunning = true
        let interval = notificationInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.nextWord()
            }
        }
    }

    func stopSchedule() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func restartSchedule() {
        if isRunning { startSchedule() }
    }

    // MARK: - History

    struct HistoryEntry: Codable, Identifiable {
        let id: UUID
        let word: String
        let phonetic: String
        let definition: String
        let timestamp: Date

        init(word: Word) {
            self.id = word.id
            self.word = word.word
            self.phonetic = word.phonetic
            self.definition = word.definition
            self.timestamp = Date()
        }
    }

    private func addToHistory(_ word: Word) {
        let entry = HistoryEntry(word: word)
        history.insert(entry, at: 0)
        if history.count > 500 { history = Array(history.prefix(500)) }
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: "history")
        }
        if let data = try? JSONEncoder().encode(Array(learnedWords)) {
            UserDefaults.standard.set(data, forKey: "learnedWords")
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "history"),
           let entries = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            history = entries
        }
        if let data = UserDefaults.standard.data(forKey: "learnedWords"),
           let ids = try? JSONDecoder().decode([UUID].self, from: data) {
            learnedWords = Set(ids)
        }
    }
}

extension Double {
    var nonZero: Double? {
        self == 0 ? nil : self
    }
}
