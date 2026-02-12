//
//  ShortcutBindingsListView.swift
//  EmacsClient
//
//  Created by Claude on 2026-02-13.
//

import SwiftUI

struct ShortcutBindingsListView: View {
	@ObservedObject var manager = ShortcutBindingsManager.shared

	var sortedBindings: [(id: String, command: EmacsCommand)] {
		manager.bindings.map { ($0.key, $0.value) }.sorted { $0.id < $1.id }
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Keyboard Shortcuts")
					.font(.headline)
				Spacer()
				Button(action: { _ = manager.addBinding() }) {
					Image(systemName: "plus")
				}
			}

			if manager.bindings.isEmpty {
				Text("No keyboard shortcuts configured.")
					.foregroundColor(.secondary)
					.padding(.vertical)
			} else {
				ForEach(sortedBindings, id: \.id) { binding in
					ShortcutRowView(
						id: binding.id,
						command: Binding(
							get: { manager.bindings[binding.id] ?? .eval("") },
							set: { manager.updateBinding(id: binding.id, command: $0) }
						),
						onDelete: { manager.removeBinding(id: binding.id) }
					)
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
