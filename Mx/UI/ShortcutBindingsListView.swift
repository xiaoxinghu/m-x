//
//  ShortcutBindingsListView.swift
//  Mx
//
//  Created by Claude on 2026-02-13.
//

import SwiftUI

// Note: This view is preserved for standalone preview use.
// The shortcuts section is rendered directly in SettingsView.
struct ShortcutBindingsListView: View {
	@ObservedObject var manager = ShortcutBindingsManager.shared

	var body: some View {
		Form {
			Section("Keyboard Shortcuts") {
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
	}
}

#Preview {
	ShortcutBindingsListView()
		.frame(width: 640)
}
