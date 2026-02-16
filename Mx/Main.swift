//
//  Main.swift
//  Mx
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import Foundation
import AppKit

func execute(_ command: String) throws -> Void {
	let process = Process()
	let outputPipe = Pipe()
	let errorPipe = Pipe()
	
	process.launchPath = "/bin/zsh"
	process.arguments = ["-c", command]
	process.standardOutput = outputPipe
	process.standardError = errorPipe
	
	try process.run()
	process.waitUntilExit()
	
	let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
	let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
	
	if let output = String(data: outputData, encoding: .utf8), !output.isEmpty {
		print(output)
	}
	
	if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
		showErrorAlert(message: errorOutput, command: command)
	}
}


func handle(_ url: URL) {
	if (url.scheme == "org-protocol") {
		emacs(.open(url))
	}
	if (url.scheme == "emacs") {
		guard let action = url.host() else { return }
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
		let query = components.queryItems ?? []
		
		
		switch action {
		case "open":
			guard let file = query.first(where: { $0.name == "file" })?.value else { return }
			guard let path = parse(path: file) else { return }
			emacs(.open(path))
		case "eval":
			guard let expr = query.first(where: { $0.name == "expr" })?.value else { return }
			let escaped = escape(expr: expr)
			print(escaped)
			emacs(.eval(escaped))
		default : break
		}
	}
}

func parse(path: String) -> URL? {
	let expandedString = path.replacingOccurrences(of: "~", with: NSHomeDirectory())
	let url = URL(string: expandedString)
	return url
}

func escape(expr: String) -> String {
	return expr.replacingOccurrences(of: "\"", with: "\\\"")
}
func showErrorAlert(message: String, command: String) {
	DispatchQueue.main.async {
		let alert = NSAlert()
		alert.messageText = "Command Execution Failed"
		alert.informativeText = message
		alert.alertStyle = .warning
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Copy Command")
		
		let response = alert.runModal()
		if response == .alertSecondButtonReturn {
			NSPasteboard.general.clearContents()
			NSPasteboard.general.setString(command, forType: .string)
		}
	}
}

