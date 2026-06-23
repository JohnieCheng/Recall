import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var manager: WordManager
    @State private var editingLibrary: CustomLibrary?
    @State private var editedName: String = ""
    @State private var isImporting = false
    @State private var selectedLanguage = L10n.currentLanguage

    var body: some View {
        Form {
            // MARK: 操作
            Section {
                Button(action: { manager.nextWord() }) {
                    Label(L10n.settingsPushNow, systemImage: "forward.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    if manager.isRunning { manager.stopSchedule() }
                    else { manager.startSchedule() }
                }) {
                    HStack {
                        Label(
                            manager.isRunning ? L10n.settingsPauseTimer : L10n.settingsStartTimer,
                            systemImage: manager.isRunning ? "pause.fill" : "play.fill"
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Circle()
                            .fill(manager.isRunning ? Color.green : Color.secondary)
                            .frame(width: 6, height: 6)
                    }
                }
                .buttonStyle(.bordered)
            } header: {
                Label(L10n.settingsSectionAction, systemImage: "bolt")
            }

            // MARK: 通知
            Section {
                Picker(L10n.settingsInterval, selection: Binding(
                    get: { manager.notificationInterval },
                    set: {
                        manager.notificationInterval = $0
                        manager.restartSchedule()
                    }
                )) {
                    ForEach(L10n.intervals, id: \.1) { item in
                        Text(item.0).tag(item.1)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Label(L10n.settingsSectionNotification, systemImage: "bell.badge")
            }

            // MARK: 语言
            Section {
                Picker(L10n.languageLabel, selection: $selectedLanguage) {
                    Text(L10n.languageEN).tag("en")
                    Text(L10n.languageZH).tag("zh")
                }
                .onChange(of: selectedLanguage) { _, newValue in
                    L10n.currentLanguage = newValue
                }
            } header: {
                Label(L10n.languageSection, systemImage: "globe")
            }

            // MARK: 朗读
            Section {
                Toggle(isOn: Binding(
                    get: { manager.speakEnabled },
                    set: { manager.speakEnabled = $0 }
                )) {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.accentColor)
                        Text(L10n.settingsSpeak)
                    }
                }
            } header: {
                Label(L10n.settingsSectionSpeak, systemImage: "speaker.wave.2")
            }

            // MARK: 状态
            Section {
                if let word = manager.currentWord {
                    HStack {
                        Label(L10n.settingsCurrentWord, systemImage: "textformat")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(word.word)
                            .fontWeight(.semibold)
                            .fontDesign(.monospaced)
                    }
                }

                HStack {
                    Label(L10n.settingsLearnedCount, systemImage: "checkmark.circle")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(manager.learnedWords.count)")
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            } header: {
                Label(L10n.settingsSectionStatus, systemImage: "chart.bar")
            }

            // MARK: 词库管理
            Section {
                ForEach(manager.customLibraries) { lib in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { lib.enabled },
                            set: { _ in manager.toggleLibrary(lib.id) }
                        ))
                        .labelsHidden()

                        VStack(alignment: .leading, spacing: 2) {
                            Text(lib.name)
                                .fontWeight(.medium)
                            Text("\(lib.words.count) \(L10n.settingsWordCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Menu {
                            Button(L10n.settingsRename) {
                                editingLibrary = lib
                                editedName = lib.name
                            }
                            Divider()
                            Button(L10n.settingsDelete, role: .destructive) {
                                manager.deleteLibrary(lib.id)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.secondary)
                        }
                        .menuStyle(.borderlessButton)
                        .frame(width: 24)
                    }
                    .padding(.vertical, 2)
                }

                Button(action: importCSV) {
                    Label(isImporting ? L10n.settingsImporting : L10n.settingsImportCSV, systemImage: "plus")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(isImporting)
            } header: {
                Label(L10n.settingsSectionLibrary, systemImage: "tray.full")
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 580)
        .sheet(item: $editingLibrary) { lib in
            renameSheet(lib: lib)
        }
    }

    // MARK: - Rename Sheet

    @ViewBuilder
    private func renameSheet(lib: CustomLibrary) -> some View {
        VStack(spacing: 16) {
            Text(L10n.settingsRenameTitle).font(.headline)
            TextField(L10n.settingsRenamePlaceholder, text: $editedName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
            HStack {
                Button(L10n.settingsCancel) { editingLibrary = nil }
                    .keyboardShortcut(.escape)
                Button(L10n.settingsConfirm) {
                    manager.renameLibrary(lib.id, to: editedName)
                    editingLibrary = nil
                }
                .keyboardShortcut(.return)
                .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding()
        .frame(width: 260, height: 140)
    }

    // MARK: - Import

    private func importCSV() {
        guard !isImporting else { return }
        isImporting = true

        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.allowsMultipleSelection = false
        panel.message = L10n.importMessage
        panel.prompt = L10n.importPrompt

        panel.begin { [self] response in
            defer { isImporting = false }
            guard response == .OK, let url = panel.url else { return }
            do {
                _ = try WordManager.shared.importWords(from: url)
            } catch {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = L10n.importFailed
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: L10n.importOK)
                    alert.runModal()
                }
            }
        }
    }
}
