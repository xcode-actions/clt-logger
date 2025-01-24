import Foundation



/* This extension in itself is very interesting and could probably be published as-is. */
internal extension String {
	
	enum NewLineProcessing {
		
		case none
		case escape
		/** The replacement is **not** escaped. */
		case replace(replacement: String)
		
	}
	
	enum EscapingMode {
		
		case none
		/**
		 The chars are escaped using the `escaped(asASCII:)` method on the scalars of the string.
		 
		 An `octothorpLevel` set to `nil` means the level will be determined automatically.
		 It is not recommended because it adds multiple searches on the string being processed.
		 It should also not be combined with showQuotes set to `false` as you cannot know the octothorp level you’ll get.
		 
		 The `whitelistedChars` are not escaped even if they should (this is provided for completeness sake and should always be an empty set).
		 There is no blacklist: only characters that need escaping are escaped. */
		case escapeScalars(asASCII: Bool = false, octothorpLevel: UInt? = 0, whitelistedChars: CharacterSet = ["'"], showQuotes: Bool = false)
		
		func octothorpLevelAndQuotes(for str: String) -> (UInt, String, String) {
			switch self {
				case .none:
					return (0, "", "")
					
				case .escapeScalars(_, let octothorpLevel?, _, false):
					return (octothorpLevel, "", "")
					
				case .escapeScalars(_, let octothorpLevel?, _, true):
					let octothorps = String(repeating: "#", count: Int(octothorpLevel))
//#if swift(>=5.4)
//					return (octothorpLevel, octothorps + #"""#, #"""# + octothorps)
//#else
					return (octothorpLevel, octothorps + "\"", "\"" + octothorps)
//#endif
					
				case .escapeScalars(_, nil, _, let showQuotes):
					/* We must determine the octothorp level. */
					var level = UInt(0)
//#if swift(>=5.4)
//					var (sepOpen, sepClose) = (#"""#, #"""#)
//#else
					var (sepOpen, sepClose) = ("\"", "\"")
//#endif
					while str.contains(sepClose) {
						level += 1
						sepOpen = "#" + sepOpen
						sepClose = sepClose + "#"
					}
					return (level, showQuotes ? sepOpen : "", showQuotes ? sepClose : "")
			}
		}
		
	}
	
	/* Idea of this function is from TextOutputStream documentation.
	 * Note: hasProcessedNewLines will return true when a new line is encountered even if the processing is to do nothing.
	 *
	 * The escaping mode is used for new lines if the new line processing is “escape”. */
	func processForLogging(escapingMode: EscapingMode = .escapeScalars(), newLineProcessing: NewLineProcessing) -> (string: String, hasProcessedNewLines: Bool) {
		let (octothorpLevel, sepOpen, sepClose) = escapingMode.octothorpLevelAndQuotes(for: self)
		let octothorps = String(repeating: "#", count: Int(octothorpLevel))
		
		var hasProcessedNewLines = false
		var specialCharState: (UnicodeScalar, Int)? = nil /* First element is the special char, the other is the number of octothorps found. */
		let ascii = unicodeScalars.lazy.map{ scalar -> String in
			/* Let’s build the previous escape if needed. */
			let prefix: String
			if scalar == "#" {
				guard let curSpecial = specialCharState else {
					return "#"
				}
				if curSpecial.1 == octothorpLevel - 1 {
					/* We have now reached the number of octothorp needed to build an actual “special char” (closing quote, backslash, etc.); we must escape it. */
					specialCharState = nil
//#if swift(>=5.4)
//					return #"\"# + octothorps + String(curSpecial.0) + octothorps
//#else
					return "\\" + octothorps + String(curSpecial.0) + octothorps
//#endif
				}
				specialCharState = (curSpecial.0, curSpecial.1 + 1)
				return ""
			} else if let curSpecial = specialCharState {
				/* We have an almost “special char”, but there are not enough octothorps to qualify; we can skip its escaping. */
				specialCharState = nil
				prefix = String(curSpecial.0) + String(repeating: "#", count: curSpecial.1)
			} else {
				prefix = ""
			}
			
			let isNewLine = Self.newLines.contains(scalar)
			if isNewLine {
				hasProcessedNewLines = true
				switch newLineProcessing {
					case .none:           return prefix + String(scalar)
					case .escape:         (/*nop*/)
					case .replace(let r): return prefix + r
				}
			}
			switch escapingMode {
				case .none:
					return prefix + String(scalar)
					
				case .escapeScalars(let asASCII, _, let whitelistedChars, _):
					guard !whitelistedChars.contains(scalar) else {
						return prefix + String(scalar)
					}
					if octothorpLevel > 0, Self.specialChars.contains(scalar) {
						/* We have a “special char” to escape but the octothorp level is greater than 0.
						 * We can maybe bypass the escaping if the special char is not followed by octothorpLevel octothorps.
						 * We register we’re building a special char and return an empty string. */
						assert(specialCharState == nil)
						specialCharState = (scalar, 0)
						return prefix + ""
					}
					let escaped = scalar.escaped(asASCII: asASCII || isNewLine)
//#if swift(>=5.4)
//					return prefix + (octothorpLevel == 0 ? escaped : escaped.replacingOccurrences(of: #"\"#, with: #"\"# + octothorps, options: .literal))
//#else
					return prefix + (octothorpLevel == 0 ? escaped : escaped.replacingOccurrences(of: "\\", with: "\\" + octothorps, options: .literal))
//#endif
			}
		}
		let asciiJoined = ascii.joined(separator: "")
		let specialCharStateMapped = (specialCharState.flatMap{ String($0.0) + String(repeating: "#", count: $0.1) } ?? "")
		return (sepOpen + asciiJoined + specialCharStateMapped + sepClose, hasProcessedNewLines)
	}
	
	private static let newLines = CharacterSet.newlines
//#if swift(>=5.4)
//	private static let specialChars = CharacterSet(charactersIn: #""\"#)
//#else
	private static let specialChars = CharacterSet(charactersIn: "\"\\")
//#endif

}
