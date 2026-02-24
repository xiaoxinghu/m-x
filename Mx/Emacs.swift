//
//  Emacs.swift
//  Mx
//
//  Created by Xiaoxing Hu on 07/04/2025.
//

import Foundation
import AppKit

enum EmacsCommand: Codable, Equatable {
	case eval(String)
	case open(URL)
}

private let emacsAppURL = URL(fileURLWithPath: "/Applications/Emacs.app")

/// Get the current mouse cursor position via NSEvent.
/// Converts from Cocoa coordinates (bottom-left origin, Y-up) to
/// screen coordinates (top-left origin, Y-down) matching Emacs and CGEvent conventions.
func mousePosition() -> CGPoint {
	let location = NSEvent.mouseLocation
	// Primary screen's height is the reference for coordinate flipping
	let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
	return CGPoint(x: location.x, y: primaryHeight - location.y)
}

func emacs(_ cmd: EmacsCommand) {
	let bin = UserDefaults.standard.string(forKey: "emacsclientPath") ?? "/usr/bin/emacsclient"

	switch cmd {
	case .open(let path):
		try? execute("\(bin) -n \"\(path.absoluteString)\"")
	case .eval(let expr):
		// Inject mouse position so elisp can determine the active monitor
		let pos = mousePosition()
		
		// Read file content if expr is a path to an elisp file, otherwise use expr as-is
		guard let elispContent = getElispCode(expr) else { return }
		let contextExpr = mxContextLetExpr(body: elispContent, mousePosition: pos)
		// Use single quotes to avoid shell escaping issues with parentheses
		let escapedExpr = contextExpr.replacingOccurrences(of: "'", with: "'\\''")
		try? execute("\(bin) -n -e '\(escapedExpr)'")
	}
}

func activateEmacsApp() {
	guard FileManager.default.fileExists(atPath: emacsAppURL.path) else { return }

	let process = Process()
	process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
	process.arguments = ["-a", emacsAppURL.path]

	do {
		try process.run()
	} catch {
		NSLog("Failed to invoke open for Emacs.app: %@", error.localizedDescription)
	}
}

private func mxContextLetExpr(body: String, mousePosition: CGPoint) -> String {
	let mouseX = Int(mousePosition.x)
	let mouseY = Int(mousePosition.y)
	return "(let ((mx--context '(:mouse-x \(mouseX) :mouse-y \(mouseY)))) \(body))"
}

/// Check if the input is a path to an existing elisp file and return its content.
/// If it's a valid elisp file path and exists, returns the file content.
/// Otherwise, returns the input string as-is.
private func getElispCode(_ input: String) -> String? {
	// Only consider it a file path if it has .el or .elisp extension
	guard input.hasSuffix(".el") || input.hasSuffix(".elisp") else {
		return input
	}

	// Expand the path (handle ~ and relative paths)
	var path = input
	if path.hasPrefix("~") {
		path = NSString(string: path).expandingTildeInPath
	}

	// Convert to absolute path if relative
	if !path.hasPrefix("/") {
		let currentDir = FileManager.default.currentDirectoryPath
		path = (currentDir as NSString).appendingPathComponent(path)
	}

	// Check if file exists
	guard FileManager.default.fileExists(atPath: path) else {
		return nil
	}

	// Read and return file content, or return input if read fails
	return (try? String(contentsOfFile: path, encoding: .utf8))
}
