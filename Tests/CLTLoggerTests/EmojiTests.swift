import Foundation
import XCTest

import Logging

@testable import CLTLogger



final class EmojiTests : XCTestCase {
	
	func testEmojiAlignmentAndTextRenderingVisually() throws {
		let envVars = ProcessInfo.processInfo.environment
		let outputEnvironment: OutputEnvironment = .detect(from: .standardError, envVars)
		for emoji in Emoji.allCases {
			let lineStr = "\(emoji.rendersAsText(in: outputEnvironment) ? "🔴" : "🟢") - \(emoji.rawValue)\(emoji.padding(for: outputEnvironment)) |"
			try FileHandle.standardError.write(contentsOf: Data((lineStr + "\n").utf8))
		}
	}
	
}
