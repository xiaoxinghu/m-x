//
//  ContentView.swift
//  EmacsClient
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

struct MenuView: View {
	@Environment(\.openWindow) var openWindow
	
	var body: some View {
		VStack {
			SettingsLink()
		}
		.padding()
	}
}

#Preview {
	MenuView()
}
