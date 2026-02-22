//
//  MxApp.swift
//  Mx
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

@main
struct MxApp: App {

	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@State var isOn = false

	var body: some Scene {


		MenuBarExtra {
			MenuView()
		} label: {
			Image("MenuBarIcon")
		}
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	static var shared: AppDelegate!
	private var settingsWindow: NSWindow?

	override init() {
		super.init()
		AppDelegate.shared = self
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		// Initialize shortcut bindings manager to register all shortcuts
		_ = ShortcutBindingsManager.shared
	}

	func application(_ application: NSApplication, open urls: [URL]) {
		urls.forEach(handle)
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		showSettings()
		return true
	}

	func showSettings() {
		if settingsWindow == nil {
			let settingsView = SettingsView()
			settingsWindow = NSWindow(
				contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
				styleMask: [.titled, .closable, .resizable],
				backing: .buffered,
				defer: false
			)
			settingsWindow?.title = "M-x Settings"
			settingsWindow?.contentView = NSHostingView(rootView: settingsView)
			settingsWindow?.center()
			settingsWindow?.isReleasedWhenClosed = false
		}
		NSApp.activate(ignoringOtherApps: true)
		settingsWindow?.makeKeyAndOrderFront(nil)
	}
}
