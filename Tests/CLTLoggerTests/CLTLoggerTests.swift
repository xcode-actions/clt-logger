import Foundation
import XCTest

@testable import CLTLogger
@testable import Logging



final class CLTLoggerTests : XCTestCase {
	
	static let multilineMode: CLTLogger.MultilineMode = .default
	
	override class func setUp() {
		/* ⚠️ Also change in the testBasicLogOutputWithAllEmojiSets method if changed here.
		 * We have not created a variable because we would have to use the @Sendable annotation, which we cannot as we support Swift 5.2. */
		LoggingSystem.bootstrap{ _ in CLTLogger(multilineMode: Self.multilineMode) }
	}
	
	/* From <https://apple.github.io/swift-log/docs/current/Logging/Protocols/LogHandler.html#treat-log-level-amp-metadata-as-values>. */
	func testFromDoc() {
		var logger1 = Logger(label: "first logger")
		logger1.logLevel = .debug
		logger1[metadataKey: "only-on"] = "first"
		
		var logger2 = logger1
		logger2.logLevel = .error                  /* This must not override `logger1`'s log level. */
		logger2[metadataKey: "only-on"] = "second" /* This must not override `logger1`'s metadata. */
		
		XCTAssertEqual(.debug, logger1.logLevel)
		XCTAssertEqual(.error, logger2.logLevel)
		XCTAssertEqual("first",  logger1[metadataKey: "only-on"])
		XCTAssertEqual("second", logger2[metadataKey: "only-on"])
	}
	
	func testVisual1() {
		XCTAssertTrue(true, "We only want to see how the log look, so please see the logs.")
		
		var logger = Logger(label: "my logger")
		logger.logLevel = .trace
		
		logger.trace("w/o metadata")
		/* Raw string is:
		 *    w/ "quotes' and # other\" #" "# \#(weirdnesses).
		 * The goal is to see the output depending on the escaping done on the text. */
		logger.info(#"w/ "quotes' and # other\" #" \#"# \#\#(weirdnesses)."#)
		
		logger[metadataKey: "from"] = #"h\]m"#
		logger.trace("with some metadata")
		logger.notice("with some metadata", metadata: ["whats_wrong": #"Shit’s got \#(SGR(.fgColorTo4BitRed).rawValue)"some colors", yo!"#])
		logger.notice("with some metadata", metadata: ["whats_wrong": #"Shit’s got\#n"a new line", yo!"#])
		logger.notice("with some metadata", metadata: ["whats_wrong": #"Shit’s got\#r"a sneaky new line", yo!"#])
		logger.notice("with some metadata", metadata: ["whats_wrong": #"Shit’s got\#u{2028}an utf8 new line", yo!"#])
		logger.notice("with some metadata", metadata: ["whats_wrong": #"Shit’s on "fire", yo!"#])
		logger.error("with some metadata", metadata: ["whats_wrong": ["the shit": #"it is on "fire", yo!"#, "bob?": "kelso"]])
		logger.warning("with some metadata", metadata: ["whats_wrong": ["the shit", "it is on", #""fire""#, "yo!"]])
		logger.critical("with some metadata", metadata: ["whats_wrong": ["the shit", "it is on", #""fire""#, "yo!"], "aaaaand": "we’re all dead"])
		
		logger[metadataKey: "from"] = nil
		logger[metadataKey: "request_id"] = "42"
		logger.warning("with some metadata")
		logger.warning("with some metadata", metadata: ["service_id": "ldap"])
		logger.warning("with some metadata", metadata: ["service_id": "ldap", "faulty_wires": ["d", "a", #"oops, has"a quote\#nand stuff"#]])
	}
	
	func testVisual2() {
		XCTAssertTrue(true, "We only want to see how the log look, so please see the logs.")
		
		var logger = Logger(label: "my logger")
		logger.logLevel = .trace
		
		CLTLogger.write(Data("\n".utf8), to: .standardError)
		
		logger.trace(   "trace:    Example of a log at this level. Isn’t it amazing?")
		logger.debug(   "debug:    Example of a log at this level. Isn’t it amazing?")
		logger.info(    "info:     Example of a log at this level. Isn’t it amazing?")
		logger.notice(  "notice:   Example of a log at this level. Isn’t it amazing?")
		logger.warning( "warning:  Example of a log at this level. Isn’t it amazing?")
		logger.error(   "error:    Example of a log at this level. Isn’t it amazing?")
		logger.critical("critical: Example of a log at this level. Isn’t it amazing?")
		
		CLTLogger.write(Data("\n".utf8), to: .standardError)
		
		logger.info("An informational message with metadata.", metadata: ["component": "LoggerTester", "array-value": .array(["1", "2", "3"]), "dictionary-value": .dictionary(["key1": "value1", "key2": "value2", "key3": "value3"])])
		
		CLTLogger.write(Data("\n".utf8), to: .standardError)
	}
	
	func testVisual3() {
		XCTAssertTrue(true, "We only want to see how the log look, so please see the logs.")
		
		var logger = Logger(label: "my logger")
		logger.logLevel = .trace
		logger.warning("Single line log")
		logger.notice("A line with \\#(escaped) characters")
		logger.notice("A log with a metadata whose key has a newline", metadata: ["new\nline": "yolo\nnow"])
		logger.trace("Mutli-line\nlog.\nHow does it feel?", metadata: ["with": "metadata"])
		logger.debug("Another multiline\nhere is the second line")
		logger.info("Another multiline\nhere is the second line")
		logger.notice("Another multiline\nhere is the second line")
		logger.warning("Another multiline\nhere is the second line")
		logger.error("Another multiline\nhere is the second line")
		logger.error("A sneaky multiline\rhere is the second line")
		logger.error("An utf8 multiline\u{0085}here is the second line")
		logger.critical("YAM!\nhere is the second line\nand why not a third one", metadata: ["with": ["metadata", "again"], "because": "42"])
	}
	
	func testBasicLogOutputWithAllEmojiSets() throws {
		XCTAssertTrue(true, "We only want to see how the log look, so please see the logs.")
		
		for emojiSet in EmojiSet.allCases {
			LoggingSystem.bootstrapInternal{ _ in CLTLogger(multilineMode: Self.multilineMode, constantsByLevel: CLTLogger.defaultConstantsByLogLevelForEmoji(on: .standardError, forcedEmojiSet: emojiSet)) }
			try FileHandle.standardError.write(contentsOf: Data("\n***** \(emojiSet.rawValue) *****\n".utf8))
			var logger = Logger(label: "my logger")
			logger.logLevel = .trace
			logger.critical("critical: Example of text at this level.")
			logger.error(   "error:    Example of text at this level.")
			logger.warning( "warning:  Example of text at this level.")
			logger.notice(  "notice:   Example of text at this level.")
			logger.info(    "info:     Example of text at this level.")
			logger.debug(   "debug:    Example of text at this level.")
			logger.trace(   "trace:    Example of text at this level.")
		}
		/* Reset factory.
		 * ⚠️ Also change in the setUp method if changed here. */
		LoggingSystem.bootstrapInternal{ _ in CLTLogger(multilineMode: Self.multilineMode) }
	}
	
}
