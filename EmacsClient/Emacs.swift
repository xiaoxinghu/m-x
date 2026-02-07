//
//  Emacs.swift
//  EmacsClient
//
//  Created by Xiaoxing Hu on 07/04/2025.
//

import Foundation

enum EmacsCommand {
	case eval(String)
	case open(URL)
}

func emacs(_ cmd: EmacsCommand) {
	let bin = UserDefaults.standard.string(forKey: "emacsclientPath") ?? "/usr/bin/emacsclient"
//	let bin: String = "/etc/profiles/per-user/xiaoxing/bin/emacsclient"

	switch cmd {
	case .open(let path):
		try? execute("\(bin) -n \"\(path.absoluteString)\"")
	case .eval(let expr):
		// Check if expr is a file path to an elisp file
		if let elispContent = readElispFileIfExists(expr) {
			// If it's a valid elisp file, eval its content
			try? execute("\(bin) -n -e \"\(elispContent.replacingOccurrences(of: "\"", with: "\\\""))\"")
		} else {
			// Otherwise treat it as elisp code
			try? execute("\(bin) -n -e \"\(expr)\"")
		}
	}
}

/// Check if the input is a path to an existing elisp file and return its content
/// Returns nil if not a valid elisp file path
private func readElispFileIfExists(_ input: String) -> String? {
	// Only consider it a file path if it has .el or .elisp extension
	guard input.hasSuffix(".el") || input.hasSuffix(".elisp") else {
		return nil
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

	// Read and return file content
	return try? String(contentsOfFile: path, encoding: .utf8)
}

