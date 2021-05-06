import Foundation

import Logging
import SystemPackage



/**
A logger designed for Command Line Tools.

A few things:
- Output is UTF8. Always.
- There is no buffering. We use `write(2)`.
- Ouptuts to stderr by default. The idea is: “usable” text (text that is
actually what the user asked for when launching your tool) should be outputted
to stdout, presumably using `print`, the rest should be on stderr. If needed you
can setup the logger to use any fd, the logger will simply `write(2)` to it.
- Ouptut has special control chars for colors if program is not compiled w/
Xcode and output fd is a tty. You can force using or force not using colors.
- If the write syscall fails, the log is lost (or partially lost; interrupts are
retried; see SystemPackage for more info).
- You can configure the logger not to automatically add a new line after each
message. By default, new lines are added.
- As this logger is specially dedicated to CLT programs, the text it outputs is
as small as possible on purpose: only the message is displayed, w/ a potential
prefix indicating the log level (or a color if colors are allowed).

A § (Xcode is dumb and needs a § here for the comment to be properly formatted).

- Note: An interesting logger is `Adorkable/swift-log-format-and-pipe`. I almost
used it (by creating extensions for a clt format and co), but ultimately
dismissed it because:
- Despite its name (which contains formatter), you are not free to choose the
log format: every message is ended w/ a `\n` (the LoggerTextOutputStreamPipe
adds the new-line directly). The only way to bypass this would be to create a
new pipe.
- It does not seems to be updated anymore (latest commit is from 2 years ago and
some code they duplicated from `apple/swift-log` has not been updated).
- To log w/o buffering (as one should for a logger?) you also have to create a
new pipe.
- Overall I love the idea of the project, but I’m not fond of the realization.
It is a feeling; I’m not sure of the reasons behind it. Might be related to the
fact that we cannot use the project as-is, or that the genericity the Adorkable
logger introduces is not really needed (creating a log handler is not complex). */
public struct CLTLogger : LogHandler {
	
	public static var defaultTextPrefixesByLogLevel: [Logger.Level: String] = {
		return [
			.trace:    "TRACE: ",
			.debug:    "DEBUG: ",
			.info:     "INFO: ",
			.notice:   "* NOTICE: ",
			.warning:  "*** WARNING: ",
			.error:    "***** ERROR: ",
			.critical: "******* CRITICAL: "
		]
	}()
	
	public static var defaultEmojiPrefixesByLogLevel: [Logger.Level: String] = {
		return [
			.trace:    "💩 ",
			.debug:    "⚙️ ",
			.info:     "📔 ",
			.notice:   "🗣 ",
			.warning:  "⚠️ ",
			.error:    "❗️ ",
			.critical: "‼️ "
		]
	}()
	
	/* Terminal does not support RGB colors, so we use 255-color palette. */
	public static var defaultColorPrefixesByLogLevel: [Logger.Level: String] = {
		func str(_ spaces: String, _ str: String, _ mods1: [SGR.Modifier], _ mods2: [SGR.Modifier]) -> String {
			return SGR.reset.rawValue + "[" + spaces + SGR(mods1).rawValue + str + SGR.reset.rawValue + "] " + SGR(mods2).rawValue
		}
		
		return [
			.trace:    str("", "TRC", [.fgColorTo256PaletteValue(247), .bold],               []),
			.debug:    str("", "DBG", [.fgColorTo4BitYellow, .bold],                         []),
			.info:     str("", "NFO", [.fgColorTo4BitGreen, .bold],                          []),
			.notice:   str("", "NTC", [.fgColorTo256PaletteValue(32), .bold],                []),
			.warning:  str("", "WRN", [.fgColorTo4BitMagenta, .bold],                        []),
			.error:    str("", "ERR", [.fgColorTo4BitRed, .bold],                            [.bold]),
			.critical: str("", "CRT", [.fgColorTo4BitBrightWhite, .bgColorTo4BitRed, .bold], [.bold])
		]
	}()
	
	public enum LogPrefixStyle {
		case none
		case text
		case emoji
		case color
		
		/** Choose text, emoji or color automatically depending on context */
		case auto
	}
	
	public var logLevel: Logger.Level = .info
	public var metadata: Logger.Metadata = [:] {
		didSet {prettyMetadataCache = prettyMetadata(metadata)}
	}
	
	public let outputFileDescriptor: FileDescriptor
	public let logPrefixesByLevel: [Logger.Level: String]
	public var lineSeparator: String
	
	/* Sadly, FileDescriptor.standardError is not available in 0.0.1 */
	public init(fd: FileDescriptor = .init(rawValue: 2), logPrefixStyle: LogPrefixStyle = .auto, lineSeparator: String = "\n") {
		let logPrefixStyle = (logPrefixStyle != .auto ? logPrefixStyle : (CLTLogger.shouldEnableColors(for: fd) ? .color : .emoji))
		
		let logPrefixesByLevel: [Logger.Level: String]
		switch logPrefixStyle {
			case .none:  logPrefixesByLevel = [:]
			case .text:  logPrefixesByLevel = CLTLogger.defaultTextPrefixesByLogLevel
			case .emoji: logPrefixesByLevel = CLTLogger.defaultEmojiPrefixesByLogLevel
			case .color: logPrefixesByLevel = CLTLogger.defaultColorPrefixesByLogLevel
			case .auto: fatalError()
		}
		let lineSeparator = (logPrefixStyle == .color ? SGR.reset.rawValue : "") + lineSeparator
		
		self.init(fd: fd, logPrefixesByLevel: logPrefixesByLevel, lineSeparator: lineSeparator)
	}
	
	public init(fd: FileDescriptor = .init(rawValue: 2), logPrefixesByLevel: [Logger.Level: String], lineSeparator: String = "\n") {
		self.outputFileDescriptor = fd
		self.logPrefixesByLevel = logPrefixesByLevel
		self.lineSeparator = lineSeparator
	}
	
	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {metadata[metadataKey]}
		set {metadata[metadataKey] = newValue}
	}
	
	public func log(level: Logger.Level, message: Logger.Message, metadata logMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		let prefix = logPrefixesByLevel[level] ?? ""
		
		let stringMetadata: String
		if let m = logMetadata, !m.isEmpty {stringMetadata = prettyMetadata(metadata.merging(m, uniquingKeysWith: { _, new in new }))}
		else                               {stringMetadata = prettyMetadataCache}
		
		let data = Data((prefix + stringMetadata + message.description + lineSeparator).utf8)
		
		/* We lock, because the writeAll function might split the write in more
		 * than 1 write (if the write system call only writes a part of the data).
		 * If another part of the program writes to fd, we might get interleaved
		 * data, because they cannot be aware of our lock (and we cannot be aware
		 * of theirs if they have one). */
		#if canImport(Darwin)
		os_unfair_lock_lock(&CLTLogger.lock)
		#else
		CLTLogger.lock.lock()
		#endif
		
		/* Is there a better idea than silently drop the message in case of fail? */
		_ = try? outputFileDescriptor.writeAll(data)
		
		#if canImport(Darwin)
		os_unfair_lock_unlock(&CLTLogger.lock)
		#else
		CLTLogger.lock.unlock()
		#endif
	}
	
	private static func shouldEnableColors(for fd: FileDescriptor) -> Bool {
		#if Xcode
		/* Xcode runs program in a tty, but does not support colors */
		return false
		#else
		return isatty(fd.rawValue) != 0
		#endif
	}
	
	#if canImport(Darwin)
	private static var lock = os_unfair_lock_s()
	#else
	/* There is probably a more efficient lock that exists… */
	private static var lock = NSLock()
	#endif
	
	private var prettyMetadataCache = ""
	
	/* Straight out of the StreamLogHandler source from Apple. */
	private func prettyMetadata(_ metadata: Logger.Metadata, level0: Bool = true) -> String {
		guard !metadata.isEmpty else {return level0 ? "" : "[:]"}
		/* Basically we’ll return "\(metadata) ", but keys will be sorted.
		 * Most of the implem was stolen from Swift source code:
		 *    https://github.com/apple/swift/blob/swift-5.3.3-RELEASE/stdlib/public/core/Dictionary.swift#L1681*/
		var result = (level0 ? "" : "[")
		var first = true
		for (k, v) in metadata.lazy.sorted(by: { $0.key < $1.key }) {
			if first {first = false}
			else     {result += (level0 ? " --- " : ", ")}
			if level0 {result += k}
			else      {debugPrint(k, terminator: "", to: &result)}
			result += (level0 ? "=" : ": ")
			debugPrint(prettyMetadataValue(v), terminator: "", to: &result)
		}
		result += (level0 ? "" : "]")
		if level0 {result += " "}
		return result
	}
	
	private func prettyMetadataValue(_ v: Logger.MetadataValue) -> String {
		/* We return basically v.description, but dictionary keys are sorted. */
		switch v {
			case .dictionary(let dict):     return prettyMetadata(dict.mapValues{ Logger.MetadataValue.string(prettyMetadataValue($0)) }, level0: false)
			case .array(let list):          return list.map{ prettyMetadataValue($0) }.description
			case .string(let str):          return str
			case .stringConvertible(let o): return o.description
		}
	}
	
	private func escape(_ str: String) -> String {
		return str
			.replacingOccurrences(of: "\\", with: "\\\\", options: .literal)
			.replacingOccurrences(of: "\"", with: "\\\"", options: .literal)
	}
	
}
