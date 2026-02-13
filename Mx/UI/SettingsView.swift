//
//  Config.swift
//  Mx
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage("emacsclientPath") private var emacsclientPath = "emacsclient"

	var body: some View {
		Form {
			Section {
				TextField("EmacsClient Path", text: $emacsclientPath)
					.textFieldStyle(RoundedBorderTextFieldStyle())
			} header: {
				Text("General")
			}

			Divider()

			Section {
				ShortcutBindingsListView()
			}
		}
		.frame(minWidth: 550, minHeight: 200)
		.padding()
	}
}

#Preview {
	SettingsView()
}
