//
//  EmacsClientApp.swift
//  EmacsClient
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

@main
struct EmacsClientApp: App {

	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@State var isOn = false

	var body: some Scene {


		MenuBarExtra {
			MenuView()
		} label: {
			Label("EmacsClient+", systemImage: "text.page.fill")
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
				contentRect: NSRect(x: 0, y: 0, width: 500, height: 150),
				styleMask: [.titled, .closable],
				backing: .buffered,
				defer: false
			)
			settingsWindow?.title = "EmacsClient+ Settings"
			settingsWindow?.contentView = NSHostingView(rootView: settingsView)
			settingsWindow?.center()
			settingsWindow?.isReleasedWhenClosed = false
		}
		NSApp.activate(ignoringOtherApps: true)
		settingsWindow?.makeKeyAndOrderFront(nil)
	}
}
