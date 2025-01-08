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
	case worm                   = "🐛"
	
	case ambulance              = "🚑"
	case ladybug                = "🐞"
	case monocle                = "🧐"
	case greenCheck             = "✅"
	case fearFace               = "😱"
	
	case greySmallSquare        = "◽️"
	case blackSmallSquare       = "◾️"
	case blueDiamond            = "🔷"
	case orangeDiamond          = "🔶"
	
	case deepRedHeart           = "♥️"
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
			case .poo, .notebook, .eyebrow, .redCross, .policeLight, .worm,
				  .orangeHeart, .yellowHeart, .greenHeart, .blueHeart, .purpleHeart,
				  .blackHeart, .brownHeart, .whiteHeart:
				return ""
				
			case .ambulance, .ladybug, .monocle, .greenCheck, .fearFace,
				  .blueDiamond, .orangeDiamond:
				return ""
				
			case .cog, .warning, .doubleExclamationPoint, .redHeart, .deepRedHeart:
				guard !environment.isVSCode, environment != .macOSTerminal
				else {return " "}
				return ""
				
			case .speaker:
				guard !environment.isVSCode, !environment.isWindowsShell, environment != .macOSTerminal, environment != .macOSiTerm2
				else {return " "}
				return ""
				
			case .exclamationPoint, .greySmallSquare, .blackSmallSquare:
				/* Note: For the Windows Terminal and Console, we need a negative 1 space!
				 * The output uses more space than most of the other emojis.
				 * We could add one space to all other emojis but there is too much space if we do this,
				 *  so instead we ask the console to go back one char when outputting these emojis. */
				guard !environment.isWindowsShell
				else {return Self.negativeOneSpace}
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
	
	/* See <https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797#cursor-controls>. */
	private static let negativeOneSpace: String = "\u{1B}[1D"
	
}
