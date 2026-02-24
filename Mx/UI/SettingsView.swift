//
//  Config.swift
//  Mx
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
	@AppStorage("emacsclientPath") private var emacsclientPath = "emacsclient"
	@State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)

	var body: some View {
		Form {
			Section {
				TextField("EmacsClient Path", text: $emacsclientPath)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				Toggle("Start on Login", isOn: $launchAtLogin)
					.onChange(of: launchAtLogin) { _, enabled in
						do {
							if enabled {
								try SMAppService.mainApp.register()
							} else {
								try SMAppService.mainApp.unregister()
							}
						} catch {
							launchAtLogin = (SMAppService.mainApp.status == .enabled)
						}
					}
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
