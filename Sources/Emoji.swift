import Foundation



internal enum Emoji : String, CaseIterable {
	
	case poo                    = "💩"
	case cog                    = "⚙️"
	case notebook               = "📔"
	case speaker                = "🗣"
	case warning                = "⚠️"
	case exclamationPoint       = "❗️"
	case doubleExclamationPoint = "‼️"
	case eyebrow                = "🤨"
	case redCross               = "❌"
	case policeLight            = "🚨"
	case ladybug                = "🐞"
	case orangeDiamond          = "🔶"
	
	case redHeart               = "❤️"
	case orangeHeart            = "🧡"
	case yellowHeart            = "💛"
	case greenHeart             = "💚"
	case blueHeart              = "💙"
	case purpleHeart            = "💜"
	case blackHeart             = "🖤"
	case greyHeart              = "🩶"
	case brownHeart             = "🤎"
	case whiteHeart             = "🤍"
	case pinkHeart              = "🩷"
	case lightBlueHeart         = "🩵"

	func padding(for environment: OutputEnvironment) -> String {
		guard environment != .xcode else {
			/* All emojis are correct on Xcode. */
			return ""
		}
		
		switch self {
			case .poo, .notebook, .eyebrow, .redCross, .policeLight, .ladybug, .orangeDiamond,
				  .orangeHeart, .yellowHeart, .greenHeart, .blueHeart, .purpleHeart,
				  .blackHeart, .brownHeart, .whiteHeart:
				return ""
				
			case .cog, .warning, .doubleExclamationPoint, .redHeart:
				guard !environment.isVSCode, environment != .macOSTerminal
				else {return " "}
				return ""
				
			case .speaker:
				guard !environment.isVSCode, !environment.isWindowsShell, environment != .macOSTerminal, environment != .macOSiTerm2
				else {return " "}
				return ""
				
			case .exclamationPoint:
				/* Note: For the Windows Terminal and Console, we’re a negative 1 space…
				 # We ignore this special case and return an empty string. */
				guard !environment.isWindowsShell
				else {return ""/*negative one space*/}
				return ""
				
			case .greyHeart, .pinkHeart, .lightBlueHeart:
				guard !environment.isVSCode
				else {return " "}
				return ""
		}
	}
	
	func valueWithPadding(for environment: OutputEnvironment) -> String {
		rawValue + padding(for: environment)
	}
	
}
