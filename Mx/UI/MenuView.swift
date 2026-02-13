//
//  ContentView.swift
//  Mx
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

struct MenuView: View {
	var body: some View {
		VStack {
			Button("Settings...") {
				AppDelegate.shared.showSettings()
			}

			Button("Quit") {
				NSApplication.shared.terminate(nil)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
		}
		.padding()
	}
}

#Preview {
	MenuView()
}
