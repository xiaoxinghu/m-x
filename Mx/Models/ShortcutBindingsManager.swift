//
//  ShortcutBindingsManager.swift
//  Mx
//
//  Created by Claude on 2026-02-13.
//

import Foundation
import KeyboardShortcuts

class ShortcutBindingsManager: ObservableObject {
	static let shared = ShortcutBindingsManager()

	@Published var bindings: [String: EmacsCommand] = [:]

	private let storageKey = "shortcutBindings"

	init() {
		loadBindings()
		registerAllShortcuts()
	}

	func loadBindings() {
		guard let data = UserDefaults.standard.data(forKey: storageKey),
			  let decoded = try? JSONDecoder().decode([String: EmacsCommand].self, from: data) else {
			return
		}
		bindings = decoded
	}

	func saveBindings() {
		guard let data = try? JSONEncoder().encode(bindings) else { return }
		UserDefaults.standard.set(data, forKey: storageKey)
	}

	@discardableResult
	func addBinding() -> String {
		let id = UUID().uuidString
		bindings[id] = .eval("")
		saveBindings()
		registerShortcut(for: id)
		return id
	}

	func updateBinding(id: String, command: EmacsCommand) {
		bindings[id] = command
		saveBindings()
	}

	func removeBinding(id: String) {
		bindings.removeValue(forKey: id)
		saveBindings()
		KeyboardShortcuts.reset(KeyboardShortcuts.Name(id))
	}

	func registerAllShortcuts() {
		for id in bindings.keys {
			registerShortcut(for: id)
		}
	}

	private func registerShortcut(for id: String) {
		let name = KeyboardShortcuts.Name(id)
		KeyboardShortcuts.onKeyUp(for: name) { [weak self] in
			guard let command = self?.bindings[id] else { return }
			emacs(command)
		}
	}
}
