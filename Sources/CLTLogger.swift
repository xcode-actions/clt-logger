import Foundation

import Logging



/**
 A logger designed for Command Line Tools.
 
 A few things:
 + Output is UTF8. Always.
 + There is no buffering. We use `write(2)`.
 + Ouptuts to stderr by default.
 The idea is: “usable” text (text that is actually what the user asked for when launching your tool) should be output to stdout,
  presumably using `print`, the rest should be on stderr.
 If needed you can setup the logger to use any file descriptor (via a FileHandle), the logger will simply `write(2)` to it.
 + Ouptut has special control chars for colors if the output fd is a tty and Xcode is not detected.
 You can force using or force not using colors.
 + If the write syscall fails, the log is lost (or partially lost; interrupts are retried; see SystemPackage for more info).
 + You can configure the logger not to automatically add a new line after each message.
 By default, new lines are added.
 + As this logger is specially dedicated to CLT programs, the text it outputs is as small as possible on purpose:
  only the message and its metadata are displayed, w/ a potential prefix indicating the log level (or a color if colors are allowed).
 + All the messages given to this logger are escaped using `scalar.escaped(asASCII: false)`,
  and the metadata keys and values are escaped using `scalar.escaped(asASCII: true)`,
  with some tweaks.
 In theory the resulting strings can be pasted in Swift code directly.
 When the quotes are visible, use those, if not, use `#""#` quotes.
 
 
 #### Note
 An interesting logger is `Adorkable/swift-log-format-and-pipe`.
 I almost used it (by creating extensions for a clt format and co), but ultimately dismissed it because:
 + Despite its name (which contains formatter), you are not free to choose the log format:
  every message is ended w/ a `\n` (the LoggerTextOutputStreamPipe adds the new-line directly).
 The only way to bypass this would be to create a new pipe.
 + It does not seem to be updated anymore (latest commit is from 2 years ago and some code they duplicated from `apple/swift-log` has not been updated).
 + To log w/o buffering (as one should for a logger?) you also have to create a new pipe.
 + Overall I love the idea of the project, but I’m not fond of the realization.
 It is a feeling; I’m not sure of the reasons behind it.
 Might be related to the fact that we cannot use the project as-is,
  or that the genericity the Adorkable logger introduces is not really needed (creating a log handler is not that complex). */
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
	 Newlines in the metadata themselves are always replaced by \n (and other special characters are escaped too).
	 
	 For now there is no option to allow multilines metadata. */
	public enum MultilineMode : CLTLogger_Sendable {
		/**
		 The new lines in logs are replaced by the given value, the metadata are printed on the same line as the log.
		 
		 This multiline log handling guarantees there will be exactly one line per log. */
		case disallowMultiline
		/**
		 The new lines in logs are replaced by the given value, the metadata are all printed on one line after the log.
		 
		 This multiline log handling guarantees there will be exactly two lines per log. */
		case disallowMultilineButMetadataOnOneNewLine
		/**
		 The new lines in logs are replaced by the given value, the metadata are all printed after the log, one line per metadata.
		 
		 This multiline log handling guarantees there will be exactly n+1 lines per log, where n is the metadata count. */
		case disallowMultilineButMetadataOnNewLines
		/**
		 Multiline logs are allowed.
		 
		 The metadata are printed on one line on the same line as the last line of the log. */
		case allowMultilineWithMetadataOnLastLine
		/**
		 Multiline logs are allowed.
		 
		 The metadata are printed on the same line as the log, _unless_ the log is multiline,
		  in which case there are printed after, one line per metadata.
		 
		 There are no options to have all the metadata on one line only if the log is multiline. */
		case allowMultilineWithMetadataOnSameLineUnlessMultiLineLogs
		/** Multiline logs are allowed and logs are printed after the log, one line per metadata (metadata are never multiline). */
		case allMultiline
		
		public static let `default` = Self.disallowMultiline
	}
	
	public struct Constants : CLTLogger_Sendable {
		
		public var logPrefix: String
		public var multilineLogPrefix: String
		public var metadataLinePrefix: String
		public var metadataSeparator: String
		public var logAndMetadataSeparator: String
		public var lineSeparator: String
		
		public init() {
			self.init(logPrefix: "", multilineLogPrefix: "", metadataLinePrefix: "meta: ", metadataSeparator: ", ", logAndMetadataSeparator: " - meta: ", lineSeparator: "\n")
		}
		
		public init(logPrefix: String, multilineLogPrefix: String, metadataLinePrefix: String, metadataSeparator: String, logAndMetadataSeparator: String, lineSeparator: String) {
			self.logPrefix = logPrefix
			self.multilineLogPrefix = multilineLogPrefix
			self.metadataLinePrefix = metadataLinePrefix
			self.metadataSeparator = metadataSeparator
			self.logAndMetadataSeparator = logAndMetadataSeparator
			self.lineSeparator = lineSeparator
		}
		
	}
	
	public var logLevel: Logger.Level = .info
	
	public var metadata: Logger.Metadata = [:] {
		didSet {flatMetadataCache = flatMetadataArray(metadata)}
	}
	public var metadataProvider: Logger.MetadataProvider?
	
	public let outputFileHandle: FileHandle
	public let multilineMode: MultilineMode
	public let constantsByLevel: [Logger.Level: Constants]
	
	public init(fileHandle: FileHandle = .standardError, multilineMode: MultilineMode = .default, logStyle: Style = .auto, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) {
		let logPrefixStyle = (logStyle != .auto ? logStyle : CLTLogger.autoLogStyle(with: fileHandle))
		
		let constantsByLevel: [Logger.Level: Constants]
		switch logPrefixStyle {
			case .none:  constantsByLevel = [:]
			case .text:  constantsByLevel = CLTLogger.defaultConstantsByLogLevelForText
			case .emoji: constantsByLevel = CLTLogger.defaultConstantsByLogLevelForEmoji(on: fileHandle)
			case .color: constantsByLevel = CLTLogger.defaultConstantsByLogLevelForColors
			case .auto: fatalError()
		}
		
		self.init(fileHandle: fileHandle, multilineMode: multilineMode, constantsByLevel: constantsByLevel, metadataProvider: metadataProvider)
	}
	
	public init(fileHandle: FileHandle = .standardError, multilineMode: MultilineMode = .default, constantsByLevel: [Logger.Level: Constants], metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) {
		self.outputFileHandle = fileHandle
		self.multilineMode = multilineMode
		self.constantsByLevel = constantsByLevel
		
		self.metadataProvider = metadataProvider
	}
	
	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {metadata[metadataKey]}
		set {metadata[metadataKey] = newValue}
	}
	
	public func log(level: Logger.Level, message: Logger.Message, metadata logMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		log(constants: constantsByLevel[level] ?? .init(), level: level, message: message, metadata: logMetadata, source: source, file: file, function: function, line: line)
	}
	
	public func log(constants: Constants, level: Logger.Level, message: Logger.Message, metadata logMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		let effectiveFlatMetadata: [String]
		if let m = mergedMetadata(with: logMetadata) {effectiveFlatMetadata = flatMetadataArray(m)}
		else                                         {effectiveFlatMetadata = flatMetadataCache}
		
		/* We compute the data to print outside of the lock. */
		let data = Self.format(message: message.description, flatMetadata: effectiveFlatMetadata, multilineMode: multilineMode, constants: constants)
		
		Self.write(data, to: outputFileHandle)
	}
	
	/** Writes to the given file descriptor like the logger would. */
	public static func write(_ data: Data, to fh: FileHandle) {
		/* We lock, because the writeAll function might split the write in more than 1 write
		 *  (if the write system call only writes a part of the data).
		 * If another part of the program writes to the file descriptor, we might get interleaved data,
		 *  because they cannot be aware of our lock (and we cannot be aware of theirs if they have one). */
		CLTLogger.lock.withLock{
			/* Is there a better idea than silently drop the message in case of fail? */
			/* Is the write retried on interrupt?
			 * We’ll assume yes, but we don’t and can’t know for sure
			 *  until FileHandle has been migrated to the open-source Foundation. */
			_ = try? fh.write(contentsOf: data)
		}
	}
	
	private static func autoLogStyle(with fh: FileHandle) -> Style {
		if let s = getenv("CLTLOGGER_LOG_STYLE") {
			switch String(cString: s) {
				case "none":  return .none
				case "color": return .color
				case "emoji": return .emoji
				case "text":  return .text
				default: (/* nop: The logger style is invalid, we infer the style as if the variable were not there. */)
			}
		}
		
		/* * * The logging style is not defined specifically in the dedicated environment value: we try and detect a correct value depending on other environmental clues. * * */
		
		/* Is the fd on which we write a tty?
		 * Most ttys nowadays support colors, with a notable exception: Xcode. */
		if isatty(fh.fileDescriptor) != 0 {
			/* Xcode detection: it ain’t trivial.
			 * I found checking for the existence of the __XCODE_BUILT_PRODUCTS_DIR_PATHS env var to be a possible solution.
			 * We could also probably check for the existence of the TERM env var: Xcode does not set it.
			 * (When Package.swift is built we can check if the value of the __CFBundleIdentifier env var is "com.apple.dt.Xcode".)
			 * The solution we’re currently using is to check whether the fd on which we write has a foreground process group as Xcode does not set one. 
			 * Note: If Xcode detection is changed here, it should also be changed in defaultConstantsByLogLevelForEmoji. */
			if tcgetpgrp(fh.fileDescriptor) == -1 && errno == ENOTTY {
				/* We log using emojis in Xcode. */
				return .emoji
			}
			/* If the TERM env var is not set we assume colors are not supported and return the text logging style. 
			 * In theory we should use the curses database to check for colors (ncurses has the `has_colors` function for this). */
			return (getenv("TERM") == nil ? .text : .color)
		}
		if let s = getenv("GITHUB_ACTIONS"), String(cString: s) == "true" {
			/* GitHub does support colors. */
			return .color
		}
		/* Unknown case: we return the text logging style. */
		return .text
	}
	
	/* Do _not_ use os_unfair_lock, apparently it is bad in Swift:
	 *  <https://twitter.com/grynspan/status/1392080373752995849>.
	 * There is OSAllocatedUnfairLock which exists and is good, but is also not available on Linux. */
	private static let lock = NSLock()
	
	private var flatMetadataCache = [String]()
	
}


public extension CLTLogger {
	
	static let defaultConstantsByLogLevelForText: [Logger.Level: Constants] = {
		func addMeta(_ str: String) -> Constants {
			let len1 = str.count - 2
			let len2 = str.trimmingCharacters(in: .init(charactersIn: "[]*")).count
			let stars = String(repeating: "*", count: len1 - len2)
			return .init(
				logPrefix: str + " ",
				multilineLogPrefix: "[" + String(repeating: "+", count: len2) + "]" + stars + " ",
				metadataLinePrefix: " meta" + stars + " - ",
				metadataSeparator: ", ",
				logAndMetadataSeparator: " --- meta: ",
				lineSeparator: "\n"
			)
		}
		return [
			.trace:    addMeta("[TRC]"),
			.debug:    addMeta("[DBG]"),
			.info:     addMeta("[NFO]"),
			.notice:   addMeta("[NTC]"),
			.warning:  addMeta("[WRN]"),
			.error:    addMeta("[ERR]*"),
			.critical: addMeta("[CRT]**")
		]
	}()
	
	static func defaultConstantsByLogLevelForEmoji(on fh: FileHandle) -> [Logger.Level: Constants] {
		func addMeta(_ str: String, _ padding: String) -> Constants {
			var str = str
			if isatty(fh.fileDescriptor) != 0, tcgetpgrp(fh.fileDescriptor) == -1, errno == ENOTTY {
				/* We’re in Xcode (probably).
				 * By default we do not do the emoji padding, unless explicitly asked to (`CLTLOGGER_TERMINAL_EMOJI` set to anything but “NO”). */
				if let s = getenv("CLTLOGGER_TERMINAL_EMOJI"), String(cString: s) != "NO" {
					str = str + padding
				}
			} else {
				/* We’re not in Xcode (probably).
				 * By default we do the emoji padding, unless explicitly asked not to (`CLTLOGGER_TERMINAL_EMOJI` set to “NO”). */
				if let s = getenv("CLTLOGGER_TERMINAL_EMOJI"), String(cString: s) == "NO" {
					/*nop*/
				} else {
					str = str + padding
				}
			}
			return .init(
				logPrefix: str + " → ",
				multilineLogPrefix: str + "   ",
				metadataLinePrefix: " ▷ ",
				metadataSeparator: " - ",
				logAndMetadataSeparator: " -- ",
				lineSeparator: "\n"
			)
		}
		/* The padding corrects alignment issues on the Terminal. */
		return [
			.trace:    addMeta("💩", ""),
			.debug:    addMeta("⚙️", " "),
			.info:     addMeta("📔", ""),
			.notice:   addMeta("🗣", " "),
			.warning:  addMeta("⚠️", " "),
			.error:    addMeta("❗️", ""),
			.critical: addMeta("‼️", " ")
		]
	}
	
	/* Terminal does not support RGB colors, so we use 255-color palette. */
	static let defaultConstantsByLogLevelForColors: [Logger.Level: Constants] = {
		func str(_ spaces: String, _ str: String, _ mods1: [SGR.Modifier], _ mods2: [SGR.Modifier]) -> Constants {
			let bgColor = SGR.Modifier.reset
			let fgColor = SGR.Modifier.fgColorTo4BitBrightBlack
			return .init(
				logPrefix: SGR(.reset, bgColor, fgColor).rawValue + "[" + spaces + SGR(mods1).rawValue + str + SGR(.reset, bgColor, fgColor).rawValue + "]" + SGR.reset.rawValue + " " + SGR(mods2).rawValue,
				multilineLogPrefix: SGR(.reset, bgColor, fgColor).rawValue + "[" + spaces + SGR(mods1).rawValue + String(repeating: "+", count: str.count) + SGR(.reset, bgColor, fgColor).rawValue + "]" + SGR.reset.rawValue + " " + SGR(mods2).rawValue,
				metadataLinePrefix: "  " + SGR(.fgColorTo4BitWhite).rawValue + "meta:" + SGR.reset.rawValue + " " + SGR(.fgColorTo256PaletteValue(245)).rawValue,
				metadataSeparator: SGR.reset.rawValue + " " + SGR(.fgColorTo4BitWhite).rawValue + "-" + SGR.reset.rawValue + " " + SGR(.fgColorTo256PaletteValue(245)).rawValue,
				logAndMetadataSeparator: SGR.reset.rawValue + " " + SGR(.fgColorTo4BitWhite).rawValue + "--" + SGR.reset.rawValue + " " + SGR(.fgColorTo256PaletteValue(245)).rawValue,
				lineSeparator: SGR.reset.rawValue + "\n"
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
	
}


/* Formatting of the log with flat metadata. */
private extension CLTLogger {
	
	/* The flatMetadata array should only contain Strings that contain only one line. */
	static func format(message: String, flatMetadata: [String], multilineMode: MultilineMode, constants: Constants) -> Data {
		switch multilineMode {
			case .disallowMultiline:
				var message = constants.logPrefix + message.processForLogging(escapingMode: .escapeScalars(octothorpLevel: 1), newLineProcessing: .escape).string
				if !flatMetadata.isEmpty {
					message += constants.logAndMetadataSeparator
				}
				message += flatMetadata.joined(separator: constants.metadataSeparator)
				message += constants.lineSeparator
				return Data(message.utf8)
				
			case .disallowMultilineButMetadataOnOneNewLine:
				var message = constants.logPrefix + message.processForLogging(escapingMode: .escapeScalars(octothorpLevel: 1), newLineProcessing: .escape).string
				if !flatMetadata.isEmpty {
					message += constants.lineSeparator + constants.metadataLinePrefix
				}
				message += flatMetadata.joined(separator: constants.metadataSeparator)
				message += constants.lineSeparator
				return Data(message.utf8)
				
			case .disallowMultilineButMetadataOnNewLines:
				var message = constants.logPrefix + message.processForLogging(escapingMode: .escapeScalars(octothorpLevel: 1), newLineProcessing: .escape).string
				message += flatMetadata.map{ constants.lineSeparator + constants.metadataLinePrefix + $0 }.joined()
				message += constants.lineSeparator
				return Data(message.utf8)
				
			case .allowMultilineWithMetadataOnLastLine:
				var message = constants.logPrefix + message.processForLogging(escapingMode: .escapeScalars(octothorpLevel: 1), newLineProcessing: .replace(replacement: constants.lineSeparator + constants.multilineLogPrefix)).string
				if !flatMetadata.isEmpty {
					message += constants.logAndMetadataSeparator
				}
				message += flatMetadata.joined(separator: constants.metadataSeparator)
				message += constants.lineSeparator
				return Data(message.utf8)
				
			case .allowMultilineWithMetadataOnSameLineUnlessMultiLineLogs:
				let (tweakedMessage, hasTweaked) = message.processForLogging(escapingMode: .escapeScalars(octothorpLevel: 1), newLineProcessing: .replace(replacement: constants.lineSeparator + constants.multilineLogPrefix))
				var message = constants.logPrefix + tweakedMessage
				if hasTweaked {
					/* We’re on a multiline case. */
					message += flatMetadata.map{ constants.lineSeparator + constants.metadataLinePrefix + $0 }.joined()
					message += constants.lineSeparator
				} else {
					/* We’re on a single line case. */
					if !flatMetadata.isEmpty {
						message += constants.logAndMetadataSeparator
					}
					message += flatMetadata.joined(separator: constants.metadataSeparator)
					message += constants.lineSeparator
				}
				return Data(message.utf8)
				
			case .allMultiline:
				var message = constants.logPrefix + message.processForLogging(escapingMode: .escapeScalars(octothorpLevel: 1), newLineProcessing: .replace(replacement: constants.lineSeparator + constants.multilineLogPrefix)).string
				message += flatMetadata.map{ constants.lineSeparator + constants.metadataLinePrefix + $0 }.joined()
				message += constants.lineSeparator
				return Data(message.utf8)
		}
	}
	
}


/* Metadata handling. */
private extension CLTLogger {
	
	/**
	 Merge the logger’s metadata, the provider’s metadata and the given explicit metadata and return the new metadata.
	 If the provider’s metadata and the explicit metadata are `nil`, returns `nil` to signify the current `flatMetadataCache` can be used. */
	func mergedMetadata(with explicit: Logger.Metadata?) -> Logger.Metadata? {
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
	
	func flatMetadataArray(_ metadata: Logger.Metadata) -> [String] {
		return metadata.lazy.sorted{ $0.key < $1.key }.map{ keyVal in
			let (key, val) = keyVal
			return (
				key.processForLogging(escapingMode: .escapeScalars(asASCII: true, octothorpLevel: 1), newLineProcessing: .escape).string +
				": " +
				prettyMetadataValue(val)
			)
		}
	}
	
	func prettyMetadataValue(_ v: Logger.MetadataValue) -> String {
		/* We return basically v.description, but dictionary keys are sorted. */
		switch v {
			case .string(let str):          return str.processForLogging(escapingMode: .escapeScalars(asASCII: true, octothorpLevel: nil, showQuotes: true), newLineProcessing: .escape).string
			case .array(let array):         return #"["# + array.map{ prettyMetadataValue($0) }.joined(separator: ", ") + #"]"#
			case .dictionary(let dict):     return #"["# +              flatMetadataArray(dict).joined(separator: ", ") + #"]"#
			case .stringConvertible(let c): return prettyMetadataValue(.string(c.description))
		}
	}
	
}
