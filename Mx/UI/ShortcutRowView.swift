//
//  ShortcutRowView.swift
//  Mx
//
//  Created by Claude on 2026-02-13.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutRowView: View {
	let id: String
	@Binding var command: EmacsCommand
	var onDelete: () -> Void

	@State private var commandType: CommandType = .eval
	@State private var textValue: String = ""

	enum CommandType: String, CaseIterable {
		case eval = "Eval"
		case open = "Open"
	}

	var body: some View {
		HStack {
			KeyboardShortcuts.Recorder(for: KeyboardShortcuts.Name(id))
				.frame(width: 150)

			Picker("", selection: $commandType) {
				ForEach(CommandType.allCases, id: \.self) { type in
					Text(type.rawValue).tag(type)
				}
			}
			.frame(width: 80)
			.onChange(of: commandType) { _, _ in
				updateCommand()
			}

			TextField(commandType == .eval ? "Elisp code" : "File path", text: $textValue)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.onChange(of: textValue) { _, _ in
					updateCommand()
				}

			Button(action: onDelete) {
				Image(systemName: "trash")
			}
			.buttonStyle(BorderlessButtonStyle())
		}
		.onAppear { syncFromCommand() }
	}

	private func syncFromCommand() {
		switch command {
		case .eval(let code):
			commandType = .eval
			textValue = code
		case .open(let url):
			commandType = .open
			textValue = url.path
		}
	}

	private func updateCommand() {
		switch commandType {
		case .eval:
			command = .eval(textValue)
		case .open:
			command = .open(URL(fileURLWithPath: textValue))
		}
	}
}
