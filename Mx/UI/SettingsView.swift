//
//  SettingsView.swift
//  Mx
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import SwiftUI
import ServiceManagement
import KeyboardShortcuts

struct SettingsView: View {
	@AppStorage("emacsclientPath") private var emacsclientPath = "emacsclient"
	@State private var launchAtLogin = (SMAppService.mainApp.status == .enabled)
	@ObservedObject private var manager = ShortcutBindingsManager.shared

	var body: some View {
		Form {
			Section("General") {
				LabeledContent("EmacsClient Path") {
					TextField("", text: $emacsclientPath)
				}
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
			}

			Section("Keyboard Shortcuts") {
				LabeledContent("Activate Emacs.app") {
					KeyboardShortcuts.Recorder(for: .activateEmacsApp)
				}

				if !manager.doubleTapPermissionGranted {
					Label {
						Text("Input Monitoring permission required for double-tap shortcuts. Enable it in System Settings → Privacy & Security → Input Monitoring.")
					} icon: {
						Image(systemName: "exclamationmark.triangle.fill")
							.foregroundStyle(.orange)
					}
					.foregroundStyle(.secondary)
				}

				ForEach(manager.bindings) { entry in
					ShortcutRowView(
						entry: entry,
						command: SwiftUI.Binding(
							get: { manager.bindings.first(where: { $0.id == entry.id })?.command ?? .eval("") },
							set: { manager.updateCommand(id: entry.id, command: $0) }
						),
						availableModifiers: manager.availableDoubleTapModifiers,
						onTriggerChange: { manager.updateTrigger(id: entry.id, to: $0) },
						onDelete: { manager.removeBinding(id: entry.id) }
					)
				}

				Button {
					manager.addBinding()
				} label: {
					Label("Add Shortcut", systemImage: "plus")
				}
				.buttonStyle(.borderless)
			}
		}
		.formStyle(.grouped)
		.frame(minWidth: 640, minHeight: 400)
	}
}

#Preview {
	SettingsView()
}
