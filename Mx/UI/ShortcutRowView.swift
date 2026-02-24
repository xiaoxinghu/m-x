//
//  ShortcutRowView.swift
//  Mx
//
//  Created by Claude on 2026-02-13.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutRowView: View {
	let entry: ShortcutEntry
	@Binding var command: EmacsCommand
	var availableModifiers: [DoubleTapModifier]  // modifiers not used by other rows
	var onTriggerChange: (ShortcutEntry.Trigger) -> Void
	var onDelete: () -> Void

	@State private var commandType: CommandType = .eval
	@State private var textValue: String = ""

	enum Mode: String, CaseIterable {
		case combo    = "Shortcut"
		case doubleTap = "Double-tap"
	}

	enum CommandType: String, CaseIterable {
		case eval = "Eval"
		case open = "Open"
	}

	var currentMode: Mode {
		if case .combo = entry.trigger { .combo } else { .doubleTap }
	}

	// Current modifier + unassigned modifiers, in declaration order
	var pickerModifiers: [DoubleTapModifier] {
		if case .doubleTap(let current) = entry.trigger {
			return DoubleTapModifier.allCases.filter { $0 == current || availableModifiers.contains($0) }
		}
		return availableModifiers
	}

	var body: some View {
		HStack {
			// Mode picker
			Picker("", selection: SwiftUI.Binding(
				get: { currentMode },
				set: { newMode in
					switch newMode {
					case .combo:
						onTriggerChange(.combo)
					case .doubleTap:
						if let mod = availableModifiers.first ?? pickerModifiers.first {
							onTriggerChange(.doubleTap(mod))
						}
					}
				}
			)) {
				ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
			}
			.frame(width: 110)

			// Trigger control
			switch entry.trigger {
			case .combo:
				KeyboardShortcuts.Recorder(for: KeyboardShortcuts.Name(entry.id))
					.frame(width: 150)
			case .doubleTap(let modifier):
				Picker("", selection: SwiftUI.Binding(
					get: { modifier },
					set: { onTriggerChange(.doubleTap($0)) }
				)) {
					ForEach(pickerModifiers) { mod in Text(mod.label).tag(mod) }
				}
				.frame(width: 150)
			}

			// Command type
			Picker("", selection: $commandType) {
				ForEach(CommandType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
			}
			.frame(width: 80)
			.onChange(of: commandType) { _, _ in updateCommand() }

			// Command value
			TextField("", text: $textValue)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.onChange(of: textValue) { _, _ in updateCommand() }

			Button(action: onDelete) { Image(systemName: "trash") }
				.buttonStyle(BorderlessButtonStyle())
		}
		.onAppear { syncFromCommand() }
	}

	private func syncFromCommand() {
		switch command {
		case .eval(let code):   commandType = .eval; textValue = code
		case .open(let url):    commandType = .open; textValue = url.path
		}
	}

	private func updateCommand() {
		switch commandType {
		case .eval: command = .eval(textValue)
		case .open: command = .open(URL(fileURLWithPath: textValue))
		}
	}
}
