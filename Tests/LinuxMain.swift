import Foundation
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
#if !os(WASI)
XCTMain(tests)

#else
/* Compilation fails for Swift <5.5… */
//await XCTMain(tests)

/* Let’s print a message to inform the tests on WASI are disabled. */
import struct CLTLogger.SGR
try FileHandle.standardError.write(contentsOf: Data("""
\(SGR(.fgColorTo4BitBrightRed, .bold).rawValue)Tests are disabled on WASI\(SGR.reset.rawValue):
\(SGR(.fgColorTo256PaletteValue(245)).rawValue)CLTLogger is compatible with Swift <5.4, so we have to add a LinuxMain file in which we call XCTMain.
On WASI the XCTMain function is async, so we have to #if the XCTMain call, one with the await keyword, the other without.
However, on Swift <5.5 the LinuxMain setup like this does not compile because the old compiler does not know the await keyword
 (even though the whole code is ignored because we do not compile for WASI when compiling with an old compiler).
I also tried doing a #if swift(>=5.5) check, but that does not work either.\(SGR.reset.rawValue)

\(SGR(.fgColorTo4BitMagenta, .bold).rawValue)To temporarily enable the tests for WASI, uncomment the `await XCTMain(tests)` line in LinuxMain.swift.\(SGR.reset.rawValue)

""".utf8))

#endif
