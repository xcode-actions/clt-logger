import Foundation

import Logging
import SystemPackage



/**
A logger designed for Command Line Tools.

A few things:
- Output is UTF8. Always.
- If the write syscall fails, the log is lost (except interrupts which are
retried; see SystemPackage for more info).
- Default CLTLogger (no-args init) will log everything below warning (excluded)
to stdout, and everything above warning (included) to stderr.
- The logger uses an os\_unfair\_lock which might not be available outside macOS
unfortunately (untested). */
public struct CLTLogger : LogHandler {
	
	public var logLevel: Logger.Level = .info
	public var metadata: Logger.Metadata = [:]
	
	public let fdMap: [Logger.Level: FileDescriptor]
	
	public init() {
		/* Sadly, standardOutput and standardError are not available in 0.0.1 */
		self.init(fdChanges: [
			.trace:    FileDescriptor.init(rawValue: 1), //.standardOutputs,
			/* Below warning, logs to stdout */
			.warning:  FileDescriptor.init(rawValue: 2)  //.standardError,
			/* Above and including warning, logs to stderr */
		])
	}
	
	public init(fdChanges: [Logger.Level: FileDescriptor?]) {
		var fdMap = [Logger.Level: FileDescriptor]()
		
		var currentFileDescriptor: FileDescriptor?
		for l in Logger.Level.allCases {
			if let newFd = fdChanges[l] {
				currentFileDescriptor = newFd
			}
			if let fd = currentFileDescriptor {
				fdMap[l] = fd
			}
		}
		self.init(fdMap: fdMap)
	}
	
	public init(fdMap: [Logger.Level: FileDescriptor]) {
		self.fdMap = fdMap
	}
	
	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {metadata[metadataKey]}
		set {metadata[metadataKey] = newValue}
	}
	
	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		guard let fd = fdMap[level] else {return}
		
		/* flockfile is only available for FILE operations, not fd. */
		os_unfair_lock_lock(&CLTLogger.lock)
		/* Is there a better idea than silently drop the message in case of fail? */
		_ = try? fd.writeAll(Data(message.description.utf8))
		os_unfair_lock_unlock(&CLTLogger.lock)
	}
	
	private static var lock = os_unfair_lock_s()
	
}
