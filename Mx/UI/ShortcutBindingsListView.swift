//
//  ShortcutBindingsListView.swift
//  Mx
//
//  Created by Claude on 2026-02-13.
//

import SwiftUI

struct ShortcutBindingsListView: View {
	@ObservedObject var manager = ShortcutBindingsManager.shared

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Keyboard Shortcuts")
					.font(.headline)
				Spacer()
				Button(action: { manager.addBinding() }) {
					Image(systemName: "plus")
				}
			}

			if !manager.doubleTapPermissionGranted {
				Text("Input Monitoring permission required for double-tap shortcuts. Enable it in System Settings → Privacy & Security → Input Monitoring.")
					.foregroundColor(.secondary)
			}

			if manager.bindings.isEmpty {
				Text("No keyboard shortcuts configured.")
					.foregroundColor(.secondary)
					.padding(.vertical)
			} else {
				ScrollView {
					VStack(spacing: 12) {
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
					}
					.padding(.trailing, 12)
				}
			}
		}
	}
}

#Preview {
	ShortcutBindingsListView()
		.padding()
		.frame(width: 600)
}
