import Foundation
import XCTest

@testable import CLTLogger



final class StringEscapingTests : XCTestCase {
	
	func testSimpleEscape() throws {
		let actual = #"This has "quotes"."#
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 0, showQuotes: true),
				newLineProcessing: .none
			).string
		let expected = #""This has \"quotes\".""#
		XCTAssertEqual(actual, expected)
	}
	
	func testWhitelistedEscape() throws {
		let actual = #"This has 'quotes'."#
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 0, whitelistedChars: ["'"]/* Already the default but let’s make it explicit for the test. */, showQuotes: true),
				newLineProcessing: .none
			).string
		let expected = #""This has 'quotes'.""#
		XCTAssertEqual(actual, expected)
	}
	
	func testSimpleEscapeLevel1() throws {
		let actual = #"This has "quotes"."#
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 1, showQuotes: true),
				newLineProcessing: .none
			).string
		let expected = ##"#"This has "quotes"."#"##
		XCTAssertEqual(actual, expected)
	}
	
	func testOctothorpEscapeLevel1() throws {
		let actual = ##"This has #"quotes"#."##
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 1, showQuotes: true),
				newLineProcessing: .none
			).string
		let expected = ##"#"This has #"quotes\#"#."#"##
		XCTAssertEqual(actual, expected)
	}
	
	func testOctothorpEscapeLevel2() throws {
		let actual = ###"This has ##"quotes"##."###
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 2, showQuotes: false),
				newLineProcessing: .none
			).string
		let expected = ###"This has ##"quotes\##"##."###
		XCTAssertEqual(actual, expected)
	}
	
	func testOctothorpEscapeAutoLevel() throws {
		let actual = ###"This has ##"quotes"##."###
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: nil, showQuotes: true),
				newLineProcessing: .none
			).string
		let expected = ####"###"This has ##"quotes"##."###"####
		XCTAssertEqual(actual, expected)
	}
	
	func testOctothorpNonEscapeAtTheEnd() throws {
		let actual = ##"This has ##"quotes"#"##
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 2, showQuotes: false),
				newLineProcessing: .none
			).string
		let expected = ##"This has ##"quotes"#"##
		XCTAssertEqual(actual, expected)
	}
	
	func testOctothorpEscapeAtTheEnd() throws {
		let actual = ###"This has ##"quotes"##"###
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 2, showQuotes: false),
				newLineProcessing: .none
			).string
		let expected = ###"This has ##"quotes\##"##"###
		XCTAssertEqual(actual, expected)
	}
	
	func testOnlyOctothorpEscapes() throws {
		let actual = ##""#"#"#"##
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 1, showQuotes: false),
				newLineProcessing: .none
			).string
		let expected = ##"\#"#\#"#\#"#"##
		XCTAssertEqual(actual, expected)
	}
	
	func testOctothorpEscapeBeforeEscapedNewLine() throws {
		let actual = ##"hi"#\##nbob"##
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 1, showQuotes: false),
				newLineProcessing: .escape
			).string
		let expected = ##"hi\#"#\#nbob"##
		XCTAssertEqual(actual, expected)
	}
	
	func testBackslashEscape() throws {
		let actual = ##"weird\#string"##
			.processForLogging(
				escapingMode: .escapeScalars(octothorpLevel: 1, showQuotes: false),
				newLineProcessing: .escape
			).string
		let expected = ##"weird\#\#string"##
		XCTAssertEqual(actual, expected)
	}
	
}
