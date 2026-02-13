//
//  MxTests.swift
//  MxTests
//
//  Created by Xiaoxing Hu on 30/03/2025.
//

import Testing
@testable import Mx
import Foundation

struct MxTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
		
//		let url = URL(string: "emacs://eval/code_here")!
		
		let target = "file:///Users/xiaoxinghu/Desktop/test.swift".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		
		var url = URL(string: "emacs://open/something/please")!
		url = url.appending(queryItems: [URLQueryItem(name: "file", value: target)])
		
		var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		var query = components.queryItems![0]
		
		print("scheme: \(String(describing: url.scheme))")
		print("str: \(url.absoluteString)")
		print("host: \(url.host())")
		print("query: \(query.name)=\(query.value ?? "nil")")
		print("lastComponent: \(url.lastPathComponent)")
		print("pathComponents: \(url.pathComponents)")
    }

}
