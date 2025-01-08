import Foundation
import XCTest

import Logging

@testable import CLTLogger



final class EmojiTests : XCTestCase {
	
	func testNoAlternateEmojiSetHasNoAlternates() {
		for env in OutputEnvironment.allCases {
			for logLevel in Logger.Level.allCases {
				let emoji = EmojiSet.noAlternates.emoji(for: logLevel, in: env)
				let rendersAsText = emoji.rendersAsText(in: env)
				XCTAssertFalse(rendersAsText)
				if rendersAsText {
					print("Found \(emoji.rawValue) which renders as text in \(env.rawValue).")
				}
			}
		}
	}
	
	func testEmojiAlignmentAndTextRenderingVisually() throws {
		let envVars = ProcessInfo.processInfo.environment
		let outputEnvironment: OutputEnvironment = .detect(from: .standardError, envVars)
		for emoji in Emoji.allCases {
			let lineStr = "\(emoji.rendersAsText(in: outputEnvironment) ? "🔴" : "🟢") - \(emoji.rawValue)\(emoji.padding(for: outputEnvironment)) |"
			try FileHandle.standardError.write(contentsOf: Data((lineStr + "\n").utf8))
		}
	}
	
}
