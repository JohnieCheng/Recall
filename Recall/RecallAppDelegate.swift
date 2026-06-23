import SwiftUI
import AppKit

@MainActor
class RecallAppDelegate: NSObject, NSApplicationDelegate {
    private var settingsWindow: NSWindow?
    private var historyWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {}

    func showSettingsWindow(manager: WordManager) {
        if let win = settingsWindow, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            win.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = SettingsView().environmentObject(manager)
        let hosting = NSHostingController(rootView: view)
        hosting.view.wantsLayer = true
        hosting.view.autoresizingMask = [.width, .height]

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        win.contentViewController = hosting
        win.title = L10n.menuSettings
        win.isReleasedWhenClosed = false
        win.hidesOnDeactivate = false
        win.delegate = self
        settingsWindow = win

        win.center()
        win.makeKeyAndOrderFront(nil)
        win.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    func showHistoryWindow(manager: WordManager) {
        if let win = historyWindow, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            win.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = HistoryView().environmentObject(manager)
        let hosting = NSHostingController(rootView: view)
        hosting.view.wantsLayer = true
        hosting.view.autoresizingMask = [.width, .height]

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        win.contentViewController = hosting
        win.title = L10n.historyTitle
        win.isReleasedWhenClosed = false
        win.hidesOnDeactivate = false
        win.delegate = self
        historyWindow = win

        win.center()
        win.makeKeyAndOrderFront(nil)
        win.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension RecallAppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let win = notification.object as? NSWindow {
            if win == settingsWindow { settingsWindow = nil }
            if win == historyWindow { historyWindow = nil }
        }
    }
}
