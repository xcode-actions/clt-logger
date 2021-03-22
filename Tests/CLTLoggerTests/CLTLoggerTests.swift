import XCTest
@testable import CLTLogger

import Logging



final class CLTLoggerTests: XCTestCase {
	
	/* From https://apple.github.io/swift-log/docs/current/Logging/Protocols/LogHandler.html#treat-log-level-amp-metadata-as-values */
	func testFromDoc() {
		LoggingSystem.bootstrap{ _ in CLTLogger() }
		var logger1 = Logger(label: "first logger")
		logger1.logLevel = .debug
		logger1[metadataKey: "only-on"] = "first"
		
		var logger2 = logger1
		logger2.logLevel = .error                  /* this must not override `logger1`'s log level */
		logger2[metadataKey: "only-on"] = "second" /* this must not override `logger1`'s metadata */
		
		XCTAssertEqual(.debug, logger1.logLevel)
		XCTAssertEqual(.error, logger2.logLevel)
		XCTAssertEqual("first",  logger1[metadataKey: "only-on"])
		XCTAssertEqual("second", logger2[metadataKey: "only-on"])
		
//		logger1.logLevel = .trace
//		logger1.trace("trace: Hello, everything is broken! You have to fix it.")
//		logger1.debug("debug: Hello, everything is broken! You have to fix it.")
//		logger1.info("info: Hello, everything is broken! You have to fix it.")
//		logger1.notice("notice: Hello, everything is broken! You have to fix it.")
//		logger1.warning("warning: Hello, everything is broken! You have to fix it.")
//		logger1.error("error: Hello, everything is broken! You have to fix it.")
//		logger1.critical("critical: Hello, everything is broken! You have to fix it.")
	}
	
}
