import Foundation

import Logging



struct CLTLogger : LogHandler {
	
	var logLevel: Logger.Level = .info
	var metadata: Logger.Metadata = [:]
	
	subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {metadata[metadataKey]}
		set {metadata[metadataKey] = newValue}
	}
	
	func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		
	}
	
}
