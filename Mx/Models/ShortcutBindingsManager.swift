//
//  ShortcutBindingsManager.swift
//  Mx
//
//  Created by Claude on 2026-02-13.
//

import Foundation
import CoreGraphics
import KeyboardShortcuts

// MARK: - DoubleTapModifier

enum DoubleTapModifier: String, Codable, CaseIterable, Identifiable, Hashable {
	case command
	case option
	case shift
	case control

	var id: String { rawValue }

	var label: String {
		switch self {
		case .command: "⌘ Command"
		case .option:  "⌥ Option"
		case .shift:   "⇧ Shift"
		case .control: "⌃ Control"
		}
	}

	var keyCodes: Set<Int> {
		switch self {
		case .command: [55, 54]
		case .option:  [58, 61]
		case .shift:   [56, 60]
		case .control: [59, 62]
		}
	}

	var flag: CGEventFlags {
		switch self {
		case .command: .maskCommand
		case .option:  .maskAlternate
		case .shift:   .maskShift
		case .control: .maskControl
		}
	}

	static func from(keyCode: Int) -> DoubleTapModifier? {
		allCases.first { $0.keyCodes.contains(keyCode) }
	}
}

// MARK: - ShortcutEntry

struct ShortcutEntry: Codable, Identifiable {
	let id: String
	var trigger: Trigger
	var command: EmacsCommand

	enum Trigger: Codable {
		case combo                      // key combo stored via KeyboardShortcuts.Name(id)
		case doubleTap(DoubleTapModifier)
	}
}

// MARK: - ShortcutBindingsManager

class ShortcutBindingsManager: ObservableObject {
	static let shared = ShortcutBindingsManager()

	@Published var bindings: [ShortcutEntry] = []
	@Published var doubleTapPermissionGranted = true

	private let storageKey = "bindings"
	private let doubleTapThreshold: CFAbsoluteTime = 0.35
	private var lastPressTimes: [DoubleTapModifier: CFAbsoluteTime] = [:]
	private var eventTap: CFMachPort?

	init() {
		loadBindings()
		registerAllShortcuts()
		setupEventTap()
	}

	// MARK: - Storage

	func loadBindings() {
		// Try current format first
		if let data = UserDefaults.standard.data(forKey: storageKey),
		   let decoded = try? JSONDecoder().decode([ShortcutEntry].self, from: data) {
			bindings = decoded
			return
		}

		// Migrate from old format (shortcutBindings stored [String: EmacsCommand])
		if let data = UserDefaults.standard.data(forKey: "shortcutBindings"),
		   let old = try? JSONDecoder().decode([String: EmacsCommand].self, from: data) {
			bindings = old.map { ShortcutEntry(id: $0.key, trigger: .combo, command: $0.value) }
			saveBindings()
			UserDefaults.standard.removeObject(forKey: "shortcutBindings")
		}
	}

	func saveBindings() {
		guard let data = try? JSONEncoder().encode(bindings) else { return }
		UserDefaults.standard.set(data, forKey: storageKey)
	}

	// MARK: - Mutations

	func addBinding() {
		let entry = ShortcutEntry(id: UUID().uuidString, trigger: .combo, command: .eval(""))
		bindings.append(entry)
		saveBindings()
		registerShortcut(for: entry.id)
	}

	func updateCommand(id: String, command: EmacsCommand) {
		guard let idx = bindings.firstIndex(where: { $0.id == id }) else { return }
		bindings[idx].command = command
		saveBindings()
	}

	func updateTrigger(id: String, to trigger: ShortcutEntry.Trigger) {
		guard let idx = bindings.firstIndex(where: { $0.id == id }) else { return }
		// Clean up old trigger
		if case .combo = bindings[idx].trigger {
			KeyboardShortcuts.reset(KeyboardShortcuts.Name(id))
		}
		bindings[idx].trigger = trigger
		saveBindings()
		// Register new trigger if switching to combo
		if case .combo = trigger {
			registerShortcut(for: id)
		}
	}

	func removeBinding(id: String) {
		guard let entry = bindings.first(where: { $0.id == id }) else { return }
		if case .combo = entry.trigger {
			KeyboardShortcuts.reset(KeyboardShortcuts.Name(id))
		}
		bindings.removeAll { $0.id == id }
		saveBindings()
	}

	// MARK: - Computed helpers

	var availableDoubleTapModifiers: [DoubleTapModifier] {
		let used = Set(bindings.compactMap { entry -> DoubleTapModifier? in
			if case .doubleTap(let mod) = entry.trigger { return mod }
			return nil
		})
		return DoubleTapModifier.allCases.filter { !used.contains($0) }
	}

	// MARK: - Shortcut registration

	func registerAllShortcuts() {
		for entry in bindings where entry.trigger == .combo {
			registerShortcut(for: entry.id)
		}
	}

	private func registerShortcut(for id: String) {
		KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name(id)) { [weak self] in
			guard let entry = self?.bindings.first(where: { $0.id == id }) else { return }
			emacs(entry.command)
		}
	}

	// MARK: - Event tap

	private func setupEventTap() {
		let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
		eventTap = CGEvent.tapCreate(
			tap: .cgSessionEventTap,
			place: .headInsertEventTap,
			options: .listenOnly,
			eventsOfInterest: mask,
			callback: { _, _, event, refcon -> Unmanaged<CGEvent>? in
				guard let refcon else { return Unmanaged.passUnretained(event) }
				let manager = Unmanaged<ShortcutBindingsManager>.fromOpaque(refcon).takeUnretainedValue()
				manager.handleFlagsChanged(event)
				return Unmanaged.passUnretained(event)
			},
			userInfo: Unmanaged.passUnretained(self).toOpaque()
		)

		guard let tap = eventTap else {
			doubleTapPermissionGranted = false
			return
		}

		let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
		CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
		CGEvent.tapEnable(tap: tap, enable: true)
	}

	private func handleFlagsChanged(_ event: CGEvent) {
		let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
		guard let modifier = DoubleTapModifier.from(keyCode: keyCode) else { return }

		guard event.flags.contains(modifier.flag) else { return }

		let allModifierFlags = CGEventFlags([.maskCommand, .maskAlternate, .maskShift, .maskControl])
		let otherHeld = event.flags.intersection(allModifierFlags).subtracting(modifier.flag)
		guard otherHeld.isEmpty else { return }

		let now = CFAbsoluteTimeGetCurrent()
		if let last = lastPressTimes[modifier], now - last < doubleTapThreshold {
			lastPressTimes[modifier] = nil
			if let entry = bindings.first(where: { if case .doubleTap(let m) = $0.trigger { m == modifier } else { false } }) {
				emacs(entry.command)
			}
		} else {
			lastPressTimes[modifier] = now
		}
	}

	deinit {
		if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
	}
}

extension ShortcutEntry.Trigger: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.combo, .combo): true
		case (.doubleTap(let a), .doubleTap(let b)): a == b
		default: false
		}
	}
}
