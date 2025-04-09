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
	var bin = UserDefaults.standard.string(forKey: "emacsclientPath") ?? "/usr/bin/emacsclient"
//	let bin: String = "/etc/profiles/per-user/xiaoxing/bin/emacsclient"

	switch cmd {
	case .open(let path):
		try? execute("\(bin) -n \"\(path.absoluteString)\"")
	case .eval(let expr):
		try? execute("\(bin) -n -e \"\(expr)\"")
	}
}

