import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

import Logging



/**
 A logger designed for Command Line Tools.
 
 A few things:
 + Output is UTF8. Always.
 + There is no buffering. We use `write(2)`.
 + Ouptuts to stderr by default.
 The idea is: “usable” text (text that is actually what the user asked for when launching your tool) should be output to stdout,
  presumably using `print`, the rest should be on stderr.
 If needed you can setup the logger to use any fd, the logger will simply `write(2)` to it.
 + Ouptut has special control chars for colors if program is not compiled w/ Xcode and output fd is a tty.
 You can force using or force not using colors.
 + If the write syscall fails, the log is lost (or partially lost; interrupts are retried; see SystemPackage for more info).
 + You can configure the logger not to automatically add a new line after each message.
 By default, new lines are added.
 + As this logger is specially dedicated to CLT programs, the text it outputs is as small as possible on purpose:
  only the message is displayed, w/ a potential prefix indicating the log level (or a color if colors are allowed).
 
 - Note: An interesting logger is `Adorkable/swift-log-format-and-pipe`.
 I almost used it (by creating extensions for a clt format and co), but ultimately dismissed it because:
 + Despite its name (which contains formatter), you are not free to choose the log format:
  every message is ended w/ a `\n` (the LoggerTextOutputStreamPipe adds the new-line directly).
 The only way to bypass this would be to create a new pipe.
 + It does not seem to be updated anymore (latest commit is from 2 years ago and some code they duplicated from `apple/swift-log` has not been updated).
 + To log w/o buffering (as one should for a logger?) you also have to create a new pipe.
 + Overall I love the idea of the project, but I’m not fond of the realization.
 It is a feeling; I’m not sure of the reasons behind it.
 Might be related to the fact that we cannot use the project as-is,
  or that the genericity the Adorkable logger introduces is not really needed (creating a log handler is not complex). */
public struct CLTLogger : LogHandler {
	
	public enum Style {
		case none
		case text
		case emoji
		case color
		
		/** Choose text, emoji or color automatically depending on context. */
		case auto
	}
	
	/**
	 How multilines logs should be handled.
	 
	 This has an impact on the log message and the placement of the metadata.
	 Newlines in the metadata themselves are always replaced by \n (and other special characters are escaped too). */
	public enum MultilineMode {
		/**
		 The new lines in logs are replaced by the given value, the metadata are printed on the same line as the log.
		 
		 This multiline log handling guarantees there will be exactly one line per log. */
		case disallowMultiline(newlinesReplacement: String)
		/**
		 The new lines in logs are replaced by the given value, the metadata are all printed on one line after the log.
		 
		 This multiline log handling guarantees there will be exactly two lines per log. */
		case disallowMultilineButMetadataOnOneNewLine(newlinesReplacement: String)
		/**
		 The new lines in logs are replaced by the given value, the metadata are all printed after the log, one line per metadata.
		 
		 This multiline log handling guarantees there will be exactly n+1 lines per log, where n is the metadata count. */
		case disallowMultilineButMetadataOnNewLines(newlinesReplacement: String)
		/**
		 Multiline logs are allowed.
		 The metadata are printed on the same line as the log, _unless_ the log is multiline,
		 in which case there are printed after, one line per metadata.
		 There is no option to have all the metadata on one line only if the log is multiline. */
		case allowMultilineWithMetadataOneSameLineUnlessMultiLineLogs
		/** Multiline logs are allowed and logs are printed after the log, one line per metadata. */
		case allMultiline
		
		public static let `default` = Self.allowMultilineWithMetadataOneSameLineUnlessMultiLineLogs
	}
	
	public struct Constants : Sendable {
		
		public var logPrefix: String
		public var multilineLogPrefix: String
		public var metadataLinePrefix: String
		public var metadataSeparator: String
		public var logAndMetadataSeparator: String
		
		public init() {
			self.init(logPrefix: "", multilineLogPrefix: "", metadataLinePrefix: "meta: ", metadataSeparator: ", ", logAndMetadataSeparator: " - meta: ")
		}
		
		public init(logPrefix: String, multilineLogPrefix: String, metadataLinePrefix: String, metadataSeparator: String, logAndMetadataSeparator: String) {
			self.logPrefix = logPrefix
			self.multilineLogPrefix = multilineLogPrefix
			self.metadataLinePrefix = metadataLinePrefix
			self.metadataSeparator = metadataSeparator
			self.logAndMetadataSeparator = logAndMetadataSeparator
		}
		
	}
	
	public static var defaultConstantsByLogLevelForText: [Logger.Level: Constants] = {
		func addMeta(_ str: String) -> Constants {
			let len1 = str.count - 2
			let len2 = str.trimmingCharacters(in: .init(charactersIn: "[ ]")).count
			let spaces = String(repeating: " ", count: (len1 - len2)/2)
			return .init(
				logPrefix: str + " ",
				multilineLogPrefix: "[" + spaces + String(repeating: "+", count: len2) + spaces + "] ",
				metadataLinePrefix: "    meta  - ",
				metadataSeparator: ", ",
				logAndMetadataSeparator: "  --- meta: "
			)
		}
		return [
			.trace:    addMeta("[   TRC   ]"),
			.debug:    addMeta("[   DBG   ]"),
			.info:     addMeta("[   NFO   ]"),
			.notice:   addMeta("[   NTC   ]"),
			.warning:  addMeta("[   WRN   ]"),
			.error:    addMeta("[  *ERR*  ]"),
			.critical: addMeta("[ **CRT** ]")
		]
	}()
	
	public static var defaultConstantsByLogLevelForEmoji: [Logger.Level: Constants] = {
		func addMeta(_ str: String, _ padding: String) -> Constants {
			let linkPadding: String
#if TERMINAL_EMOJI
			let str = str + padding
			linkPadding = " "
#else
			linkPadding = ""
#endif
			return .init(
				logPrefix: str + " ",
				multilineLogPrefix: str + " ◦ ",
				metadataLinePrefix: str + " ⛓ " + linkPadding,
				metadataSeparator: " - ",
				logAndMetadataSeparator: " -- "
			)
		}
		/* The padding correct alignment issues. */
		return [
			.trace:    addMeta("💩", ""),
			.debug:    addMeta("⚙️", " "),
			.info:     addMeta("📔", ""),
			.notice:   addMeta("🗣", " "),
			.warning:  addMeta("⚠️", " "),
			.error:    addMeta("❗️", ""),
			.critical: addMeta("‼️", " ")
		]
	}()
	
	/* Terminal does not support RGB colors, so we use 255-color palette. */
	public static var defaultConstantsByLogLevelForColors: [Logger.Level: Constants] = {
		func str(_ spaces: String, _ str: String, _ mods1: [SGR.Modifier], _ mods2: [SGR.Modifier]) -> Constants {
			let bgColor = SGR.Modifier.reset
			let fgColor = SGR.Modifier.fgColorTo4BitBrightBlack
			return .init(
				logPrefix: SGR(.reset, bgColor, fgColor).rawValue + "[" + spaces + SGR(mods1).rawValue + str + SGR(.reset, bgColor, fgColor).rawValue + "]" + SGR.reset.rawValue + " " + SGR(mods2).rawValue,
				multilineLogPrefix: SGR(.reset, bgColor, fgColor).rawValue + "[" + spaces + SGR(mods1).rawValue + String(repeating: "+", count: str.count) + SGR(.reset, bgColor, fgColor).rawValue + "]" + SGR.reset.rawValue + " " + SGR(mods2).rawValue,
				metadataLinePrefix: "  " + SGR(.fgColorTo4BitWhite).rawValue + "meta:" + SGR.reset.rawValue + " " + SGR(.fgColorTo256PaletteValue(245)).rawValue,
				metadataSeparator: SGR.reset.rawValue + " " + SGR(.fgColorTo4BitWhite).rawValue + "-" + SGR.reset.rawValue + " " + SGR(.fgColorTo256PaletteValue(245)).rawValue,
				logAndMetadataSeparator: SGR(.reset).rawValue + " " + SGR(.fgColorTo4BitWhite).rawValue + "--" + SGR.reset.rawValue + " " + SGR(.fgColorTo256PaletteValue(245)).rawValue
			)
		}
		
		return [
			.trace:    str("", "TRC", [.fgColorTo256PaletteValue(247), .bold],                     []),
			.debug:    str("", "DBG", [.fgColorTo4BitYellow, .bold],                               []),
			.info:     str("", "NFO", [.fgColorTo4BitGreen, .bold],                                []),
			.notice:   str("", "NTC", [.fgColorTo4BitCyan, .bold],                                 []),
			.warning:  str("", "WRN", [.fgColorTo4BitBrightMagenta, .bold],                        []),
			.error:    str("", "ERR", [.fgColorTo4BitBrightRed, .bold],                            [.bold]),
			.critical: str("", "CRT", [.fgColorTo4BitBrightWhite, .bgColorTo4BitBrightRed, .bold], [.bold])
		]
	}()
	
	public var logLevel: Logger.Level = .info
	
	public var metadata: Logger.Metadata = [:] {
		didSet {flatMetadataCache = flatMetadataArray(metadata)}
	}
	public var metadataProvider: Logger.MetadataProvider?
	
	public let outputFileDescriptor: FileDescriptor
	public let multilineMode: MultilineMode
	public let constantsByLevel: [Logger.Level: Constants]
	public let lineSeparator: String
	
	public init(fd: FileDescriptor = .standardError, multilineMode: MultilineMode = .default, logStyle: Style = .auto, lineSeparator: String = "\n", metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) {
		let logPrefixStyle = (logStyle != .auto ? logStyle : (CLTLogger.shouldEnableColors(for: fd) ? .color : .emoji))
		
		let constantsByLevel: [Logger.Level: Constants]
		switch logPrefixStyle {
			case .none:  constantsByLevel = [:]
			case .text:  constantsByLevel = CLTLogger.defaultConstantsByLogLevelForText
			case .emoji: constantsByLevel = CLTLogger.defaultConstantsByLogLevelForEmoji
			case .color: constantsByLevel = CLTLogger.defaultConstantsByLogLevelForColors
			case .auto: fatalError()
		}
		let lineSeparator = (logPrefixStyle == .color ? SGR.reset.rawValue : "") + lineSeparator
		
		self.init(fd: fd, multilineMode: multilineMode, constantsByLevel: constantsByLevel, lineSeparator: lineSeparator, metadataProvider: metadataProvider)
	}
	
	public init(fd: FileDescriptor = .standardError, multilineMode: MultilineMode = .default, constantsByLevel: [Logger.Level: Constants], lineSeparator: String = "\n", metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) {
		self.outputFileDescriptor = fd
		self.multilineMode = multilineMode
		self.constantsByLevel = constantsByLevel
		self.lineSeparator = lineSeparator
		
		self.metadataProvider = metadataProvider
	}
	
	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {metadata[metadataKey]}
		set {metadata[metadataKey] = newValue}
	}
	
	public func log(level: Logger.Level, message: Logger.Message, metadata logMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		let constants = constantsByLevel[level] ?? .init()
		
		let effectiveFlatMetadata: [String]
		if let m = mergedMetadata(with: logMetadata) {effectiveFlatMetadata = flatMetadataArray(m)}
		else                                         {effectiveFlatMetadata = flatMetadataCache}
		
		/* We compute the data to print outside of the lock. */
		let data = format(message: message.description, flatMetadata: effectiveFlatMetadata, constants: constants)
		
		/* We lock, because the writeAll function might split the write in more than 1 write
		 *  (if the write system call only writes a part of the data).
		 * If another part of the program writes to fd, we might get interleaved data,
		 *  because they cannot be aware of our lock (and we cannot be aware of theirs if they have one). */
		CLTLogger.lock.withLock{
			/* Is there a better idea than silently drop the message in case of fail? */
			_ = try? outputFileDescriptor.writeAll(data)
		}
	}
	
	private static func shouldEnableColors(for fd: FileDescriptor) -> Bool {
#if Xcode
		/* Xcode runs program in a tty, but does not support colors. */
		return false
#else
		return isatty(fd.rawValue) != 0
#endif
	}
	
	/* Do _not_ use os_unfair_lock, apparently it is bad in Swift:
	 *  https://twitter.com/grynspan/status/1392080373752995849 */
	private static var lock = NSLock()
	
	private var flatMetadataCache = [String]()
	
}


/* Formatting of the log with flat metadata. */
extension CLTLogger {
	
	func format(message: String, flatMetadata: [String], constants: Constants) -> Data {
		switch multilineMode {
			case .disallowMultiline(newlinesReplacement: let r):
				var message = constants.logPrefix + message.replacingNewlines(with: r).string
				if !flatMetadata.isEmpty {
					message += constants.logAndMetadataSeparator
				}
				message += flatMetadata.joined(separator: constants.metadataSeparator)
				message += lineSeparator
				return Data(message.utf8)
				
			case .disallowMultilineButMetadataOnOneNewLine(newlinesReplacement: let r):
				var message = constants.logPrefix + message.replacingNewlines(with: r).string
				if !flatMetadata.isEmpty {
					message += lineSeparator + constants.metadataLinePrefix
				}
				message += flatMetadata.joined(separator: constants.metadataSeparator)
				message += lineSeparator
				return Data(message.utf8)
				
			case .disallowMultilineButMetadataOnNewLines(newlinesReplacement: let r):
				var message = constants.logPrefix + message.replacingNewlines(with: r).string
				message += flatMetadata.map{ lineSeparator + constants.metadataLinePrefix + $0 }.joined()
				message += lineSeparator
				return Data(message.utf8)
				
			case .allowMultilineWithMetadataOneSameLineUnlessMultiLineLogs:
				let (tweakedMessage, hasTweaked) = message.replacingNewlines(with: lineSeparator + constants.multilineLogPrefix)
				var message = constants.logPrefix + tweakedMessage
				if hasTweaked {
					/* We’re on a multiline case. */
					message += flatMetadata.map{ lineSeparator + constants.metadataLinePrefix + $0 }.joined()
					message += lineSeparator
				} else {
					/* We’re on a single line case. */
					if !flatMetadata.isEmpty {
						message += constants.logAndMetadataSeparator
					}
					message += flatMetadata.joined(separator: constants.metadataSeparator)
					message += lineSeparator
				}
				return Data(message.utf8)
				
			case .allMultiline:
				var message = constants.logPrefix + message.replacingNewlines(with: lineSeparator + constants.multilineLogPrefix).string
				message += flatMetadata.map{ lineSeparator + constants.metadataLinePrefix + $0 }.joined()
				message += lineSeparator
				return Data(message.utf8)
		}
	}
	
}


/* Metadata handling. */
extension CLTLogger {
	
	/**
	 Merge the logger’s metadata, the provider’s metadata and the given explicit metadata and return the new metadata.
	 If the provider’s metadata and the explicit metadata are `nil`, returns `nil` to signify the current `flatMetadataCache` can be used. */
	private func mergedMetadata(with explicit: Logger.Metadata?) -> Logger.Metadata? {
		var metadata = metadata
		let provided = metadataProvider?.get() ?? [:]
		
		guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
			/* All per-log-statement values are empty or not set: we return nil. */
			return nil
		}
		
		if !provided.isEmpty {
			metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
		}
		if let explicit = explicit, !explicit.isEmpty {
			metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
		}
		return metadata
	}
	
	private func flatMetadataArray(_ metadata: Logger.Metadata) -> [String] {
		return metadata.lazy.sorted{ $0.key < $1.key }.map{ keyVal in
			let (key, val) = keyVal
			return key + ": " + prettyMetadataValue(val, isFromRoot: true)
		}
	}
	
	private func flatMetadata(_ metadata: Logger.Metadata) -> String {
		guard !metadata.isEmpty else {return "[:]"}
		
		/* Basically we’ll return "\(metadata) ", but keys will be sorted.
		 * Most of the implem was stolen from Swift source code:
		 *    https://github.com/apple/swift/blob/swift-5.3.3-RELEASE/stdlib/public/core/Dictionary.swift#L1681 */
		var result = "["
		var first = true
		for (k, v) in metadata.lazy.sorted(by: { $0.key < $1.key }) {
			if first {first = false}
			else     {result += ", "}
			debugPrint(k, terminator: "", to: &result)
			result += ": "
			debugPrint(prettyMetadataValue(v, isFromRoot: false), terminator: "", to: &result)
		}
		result += "]"
		return result
	}
	
	private func prettyMetadataValue(_ v: Logger.MetadataValue, isFromRoot: Bool) -> String {
		/* We return basically v.description, but dictionary keys are sorted. */
		switch v {
			case .string(let str):          return (!isFromRoot ? str : str.debugDescription)
			case .stringConvertible(let o): return (!isFromRoot ? o.description : o.description.debugDescription)
			case .array(let list):          return list.map{ prettyMetadataValue($0, isFromRoot: false) }.description
			case .dictionary(let dict):     return flatMetadata(dict.mapValues{ Logger.MetadataValue.string(prettyMetadataValue($0, isFromRoot: false)) })
		}
	}
	
}
