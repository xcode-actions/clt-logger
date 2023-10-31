import XCTest
@testable import CLTLogger

import Logging



final class CLTLoggerTests: XCTestCase {
	
	override class func setUp() {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
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
		logger.trace(   "trace:    Example of text at this level. Isn’t it amazing?")
		logger.debug(   "debug:    Example of text at this level. Isn’t it amazing?")
		logger.info(    "info:     Example of text at this level. Isn’t it amazing?")
		logger.notice(  "notice:   Example of text at this level. Isn’t it amazing?")
		logger.warning( "warning:  Example of text at this level. Isn’t it amazing?")
		logger.error(   "error:    Example of text at this level. Isn’t it amazing?")
		logger.critical("critical: Example of text at this level. Isn’t it amazing?")
	}
	
	func testVisual3() {
		XCTAssertTrue(true, "We only want to see how the log look, so please see the logs.")
		
		var logger = Logger(label: "my logger")
		logger.logLevel = .trace
		logger.warning("Single line log")
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
	
}
