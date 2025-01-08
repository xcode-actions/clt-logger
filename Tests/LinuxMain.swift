import XCTest

@testable import CLTLoggerTests

var tests: [XCTestCaseEntry] = [
	testCase([
		("testFromDoc", CLTLoggerTests.testFromDoc),
		("testVisual1", CLTLoggerTests.testVisual1),
		("testVisual2", CLTLoggerTests.testVisual2),
		("testVisual3", CLTLoggerTests.testVisual3),
		("testBasicLogOutputWithAllEmojiSets", CLTLoggerTests.testBasicLogOutputWithAllEmojiSets),
	]),
	testCase([
		("testNoAlternateEmojiSetHasNoAlternates", EmojiTests.testNoAlternateEmojiSetHasNoAlternates),
		("testEmojiAlignmentAndTextRenderingVisually", EmojiTests.testEmojiAlignmentAndTextRenderingVisually),
	]),
	testCase([
		("testSGRParseFail", SGRTests.testSGRParseFail),
		("testSGRParse", SGRTests.testSGRParse),
		("testMultipleSGRParse", SGRTests.testMultipleSGRParse),
		("testVisual1", SGRTests.testVisual1),
	]),
	testCase([
		("testSimpleEscape", StringEscapingTests.testSimpleEscape),
		("testWhitelistedEscape", StringEscapingTests.testWhitelistedEscape),
		("testSimpleEscapeLevel1", StringEscapingTests.testWhitelistedEscape),
		("testOctothorpEscapeLevel1", StringEscapingTests.testOctothorpEscapeLevel1),
		("testOctothorpEscapeLevel2", StringEscapingTests.testOctothorpEscapeLevel2),
		("testOctothorpEscapeAutoLevel", StringEscapingTests.testOctothorpEscapeAutoLevel),
		("testOctothorpNonEscapeAtTheEnd", StringEscapingTests.testOctothorpNonEscapeAtTheEnd),
		("testOctothorpEscapeAtTheEnd", StringEscapingTests.testOctothorpEscapeAtTheEnd),
		("testOnlyOctothorpEscapes", StringEscapingTests.testOnlyOctothorpEscapes),
		("testOctothorpEscapeBeforeEscapedNewLine", StringEscapingTests.testOctothorpEscapeBeforeEscapedNewLine),
		("testBackslashEscape", StringEscapingTests.testBackslashEscape),
	]),
]
XCTMain(tests)
