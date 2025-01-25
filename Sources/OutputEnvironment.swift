import Foundation



internal enum OutputEnvironment : String, CaseIterable {
	
	case xcode = "XCODE"
	
	case macOSTerminal = "MACOS_TERMINAL"
	case macOSiTerm2   = "MACOS_ITERM2"
	case macOSVSCode   = "MACOS_VSCODE"
	case macOSUnknown  = "MACOS_UNKNOWN"
	
	/* This value is never auto-detected.
	 * We don’t know how to detect the Windows Terminal (TERM_PROGRAM is not set). */
	case windowsTerminal = "WINDOWS_TERMINAL"
	/* This value is never auto-detected.
	 * We don’t know how to detect the Windows Console. */
	case windowsConsole  = "WINDOWS_CONSOLE"
	case windowsVSCode   = "WINDOWS_VSCODE"
	case windowsUnknown  = "WINDOWS_UNKNOWN"
	
	case unknownVSCode = "UNKNOWN_VSCODE"
	case unknown = "UNKNOWN"
	
	var isVSCode: Bool {
		switch self {
			case .macOSVSCode, .windowsVSCode, .unknownVSCode: return true
			default:                                           return false
		}
	}
	
	var isWindowsShell: Bool {
		switch self {
			case .windowsTerminal, .windowsConsole, .windowsUnknown: return true
			default:                                                 return false
		}
	}
	
	static func detect(from fh: FileHandle, _ envVars: [String: String] = ProcessInfo.processInfo.environment) -> OutputEnvironment {
		if let envStr = envVars["CLTLOGGER_OUTPUT_ENV"] {
			return OutputEnvironment(rawValue: envStr) ?? .unknown
		}
		
#if canImport(Darwin)
		/* Let’s detect Xcode. */
		if isatty(fh.fileDescriptor) != 0 && tcgetpgrp(fh.fileDescriptor) == -1 && errno == ENOTTY {
			return .xcode
		}
#endif
		switch envVars["TERM_PROGRAM"] {
			case "Apple_Terminal":
#if os(macOS)
				return .macOSTerminal
#else
				return .unknown
#endif
				
			case "iTerm.app":
#if os(macOS)
				return .macOSiTerm2
#else
				return .unknown
#endif
				
			case "vscode":
#if os(macOS)
				return .macOSVSCode
#elseif os(Windows)
				return .windowsVSCode
#else
				return .unknownVSCode
#endif
				
			default:
#if os(macOS)
				return .macOSUnknown
#elseif os(Windows)
				/* We don’t know how to detect the Windows Terminal env:
				 *  anything we have not previously detected on Windows is the Terminal. */
				return .windowsTerminal
#else
				return .unknown
#endif
		}
	}
	
}
