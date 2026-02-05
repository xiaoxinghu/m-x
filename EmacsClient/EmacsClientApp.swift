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
		
		Settings {
			SettingsView()
		}
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	func application(_ application: NSApplication, open urls: [URL]) {
		urls.forEach(handle)
	}
}
