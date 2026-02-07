//
//  ContentView.swift
//  EmacsClient
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

struct MenuView: View {
	@Environment(\.openWindow) var openWindow
	@Environment(\.openSettings) private var openSettings

	var body: some View {
		VStack {
			Button("Settings...") {
				// Activate the app first to bring windows to front
				NSApplication.shared.activate(ignoringOtherApps: true)
				// Then open settings
				openSettings()
			}
		}
		.padding()
	}
}

#Preview {
	MenuView()
}
