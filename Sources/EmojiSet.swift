import Foundation

import Logging



internal enum EmojiSet : String, CaseIterable {
	
	/**
	 The original set of emoji used in clt-logger.
	 These work well in Terminal and Xcode (and on macOS generally, though not in VSCode). */
	case original                  = "ORIGINAL"
	case swiftyBeaver              = "SWIFTY_BEAVER"
	case cleanroomLogger           = "CLEANROOM_LOGGER"
	case vaibhavsingh97EmojiLogger = "VAIBHAVSINGH97_EMOJI_LOGGER"
	
	/** The emoji set that works on all platforms (no need for a replacement emoji because the original renders as text). */
	case noAlternates = "NO_ALTERNATES"
	
	static func `default`(for environment: OutputEnvironment, _ envVars: [String: String] = ProcessInfo.processInfo.environment) -> EmojiSet {
		if let envStr = envVars["CLTLOGGER_EMOJI_SET_NAME"], let ret = EmojiSet(rawValue: envStr) {
			return ret
		}
		return .original
	}
	
	func emoji(for logLevel: Logger.Level, in environment: OutputEnvironment) -> Emoji {
		let ret: Emoji
		switch self {
			case .original:
				switch logLevel {
					case .critical: ret = .doubleExclamationPoint
					case .error:    ret = .exclamationPoint
					case .warning:  ret = .warning
					case .notice:   ret = .speaker
					case .info:     ret = .notebook
					case .debug:    ret = .cog
					case .trace:    ret = .poo
				}
				
			case .swiftyBeaver:
				switch logLevel {
					case .critical: ret = .redSquare
					case .error:    ret = .redSquare
					case .warning:  ret = .yellowSquare
					case .notice:   ret = .blueSquare /* Log level does not exist in upstream. */
					case .info:     ret = .blueSquare
					case .debug:    ret = .greenSquare
					case .trace:    ret = .whiteSquare
				}
				
			case .cleanroomLogger:
				switch logLevel {
					case .critical: ret = .redCross /* Log level does not exist in upstream. */
					case .error:    ret = .redCross
					case .warning:  ret = .orangeDiamond
					case .notice:   ret = .blueDiamond /* Log level does not exist in upstream. */
					case .info:     ret = .blueDiamond
					case .debug:    ret = .blackSmallSquare
					case .trace:    ret = .greySmallSquare
				}
				
			case .vaibhavsingh97EmojiLogger:
				switch logLevel {
					case .critical: ret = .ambulance
					case .error:    ret = .fearFace
					case .warning:  ret = .warning
					case .notice:   ret = .greenCheck /* Called success in upstream. */
					case .info:     ret = .monocle
					case .debug:    ret = .ladybug
					case .trace:    ret = .ladybug /* Log level does not exist in upstream. */
				}
				
			case .noAlternates:
				switch logLevel {
					case .critical: return .redCross
					case .error:    return .redCircle
					case .warning:  return .orangeCircle
					case .notice:   return .yellowCircle
					case .info:     return .greenCircle
					case .debug:    return .purpleCircle
					case .trace:    return .whiteCircle
				}
		}
		guard ret.rendersAsText(in: environment) else {
			return ret
		}
		/* The no alternates emoji set will not check if its returned emojis render as text so there will never be an infinite loop here. */
		return EmojiSet.noAlternates.emoji(for: logLevel, in: environment)
	}
	
	func paddedEmoji(for logLevel: Logger.Level, in environment: OutputEnvironment) -> String {
		return emoji(for: logLevel, in: environment).valueWithPadding(for: environment)
	}
	
}
