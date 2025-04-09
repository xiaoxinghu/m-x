//
//  Main.swift
//  EmacsClient
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import Foundation

func execute(_ command: String) throws -> Void {
	print("exe \(command)")
	let process = Process()
	let pipe = Pipe()
	
	process.launchPath = "/bin/zsh"
	process.arguments = ["-c", command]
	process.standardOutput = pipe
	
	try process.run()
	process.waitUntilExit()
	
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	guard let output = String(data: data, encoding: .utf8) else { return }
	print(output)
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
