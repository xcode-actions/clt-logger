import Foundation

import Logging



internal enum EmojiSet : String {
	
	/**
	 The original set of emoji used in clt-logger.
	 These work well in Terminal and Xcode (and on macOS generally, though not in VSCode). */
	case original                   = "ORIGINAL"
	case originalForWindowsTerminal = "ORIGINAL+WINDOWS_TERMINAL"
	case originalForVSCodeMacOS     = "ORIGINAL+VSCODE_MACOS"
	case originalForVSCodeWindows   = "ORIGINAL+VSCODE_WINDOWS"
	
	case vaibhavsingh97EmojiLogger               = "VAIBHAVSINGH97_EMOJI_LOGGER"
	case vaibhavsingh97EmojiLoggerForVSCodeMacOS = "VAIBHAVSINGH97_EMOJI_LOGGER+VSCODE_MACOS"
	
	static func `default`(for environment: OutputEnvironment, _ envVars: [String: String] = ProcessInfo.processInfo.environment) -> EmojiSet {
		if let envStr = envVars["CLTLOGGER_EMOJI_SET_NAME"], let ret = EmojiSet(rawValue: envStr) {
			return ret
		}
		switch environment {
			case .xcode, .macOSTerminal, .macOSiTerm2, .macOSUnknown:
				return .original
				
			case .macOSVSCode, .unknownVSCode, .unknown:
				return .originalForVSCodeMacOS
				
			case .windowsTerminal, .windowsConsole, .windowsUnknown:
				return .originalForWindowsTerminal
				
			case .windowsVSCode:
				return .originalForVSCodeWindows
		}
	}
	
	/* Exceptions:
	 * - ⚙️ on VSCode macOS renders as text
	 * - ⚠️ on VSCode macOS renders as text
	 * - ‼️ on VSCode macOS renders as text
	 * - ❤️ on VSCode macOS renders as text
	 * - 🗣 on VSCode Windows renders as text (I think)
	 * - ‼️ on VSCode Windows renders as text
	 * - ❗️ on Windows Terminal is larger than the rest (negative padding would be needed)
	 * - ‼️ on Windows Terminal renders as text */
	func emoji(for logLevel: Logger.Level) -> Emoji {
		let original: (Logger.Level) -> Emoji = {
			switch $0 {
				case .critical: return .doubleExclamationPoint
				case .error:    return .exclamationPoint
				case .warning:  return .warning
				case .notice:   return .speaker
				case .info:     return .notebook
				case .debug:    return .cog
				case .trace:    return .poo
			}
		}
		let vaibhavsingh97: (Logger.Level) -> Emoji = {
			switch $0 {
				case .critical: return .ambulance
				case .error:    return .fearFace
				case .warning:  return .warning
				case .notice:   return .greenCheck /* Called success in upstream. */
				case .info:     return .monocle
				case .debug:    return .ladybug
				case .trace:    return .poo /* Does not exist in upstream. */
			}
		}
		
		switch self {
			case .original:
				return original(logLevel)
				
			case .originalForWindowsTerminal:
				switch logLevel {
					case .critical: return .policeLight
					case .error:    return .redCross
					default:        return original(logLevel)
				}
				
			case .originalForVSCodeMacOS:
				switch logLevel {
					case .critical: return .policeLight
					case .warning:  return .orangeDiamond
					case .debug:    return .worm
					default:        return original(logLevel)
				}
				
			case .originalForVSCodeWindows:
				switch logLevel {
					case .critical: return .policeLight
					case .notice:   return .eyebrow
					default:        return original(logLevel)
				}
				
			case .vaibhavsingh97EmojiLogger:
				return vaibhavsingh97(logLevel)
				
			case .vaibhavsingh97EmojiLoggerForVSCodeMacOS:
				switch logLevel {
					case .warning: return .orangeDiamond
					default:       return vaibhavsingh97(logLevel)
				}
		}
	}
	
	func paddedEmoji(for logLevel: Logger.Level, in environment: OutputEnvironment) -> String {
		return emoji(for: logLevel).valueWithPadding(for: environment)
	}
	
}
