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
	
#if swift(>=5.2) || (!os(macOS) && !os(iOS) && !os(tvOS) && !os(watchOS))
	@available(macOS 10.15.4, *)
	@available(iOS 13.4, *)
	@available(tvOS 13.4, *)
	@available(watchOS 6.2, *)
	func testEmojiAlignmentAndTextRenderingVisually() throws {
		let envVars = ProcessInfo.processInfo.environment
		let outputEnvironment: OutputEnvironment = .detect(from: .standardError, envVars)
		for emoji in Emoji.allCases {
			let lineStr = "\(emoji.rendersAsText(in: outputEnvironment) ? "🔴" : "🟢") - \(emoji.rawValue)\(emoji.padding(for: outputEnvironment)) |"
			try FileHandle.standardError.write(contentsOf: Data((lineStr + "\n").utf8))
		}
	}
#endif
	
}
