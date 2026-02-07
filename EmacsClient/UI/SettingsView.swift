//
//  Config.swift
//  EmacsClient
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI

struct SettingsView: View {
	@AppStorage("emacsclientPath") private var emacsclientPath = "emacsclient"
	
	var body: some View {
		Form {
			TextField("EmacsClient Path", text: $emacsclientPath)
				.textFieldStyle(RoundedBorderTextFieldStyle())
		}
		.frame(maxWidth: 500)
		.padding()
	}
}

#Preview {
	SettingsView()
}
