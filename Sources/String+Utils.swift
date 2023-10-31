import Foundation



internal extension String {
	
	enum NewLineProcessing {
		
		case none
		case escapeAsASCII
		case replace(replacement: String)
		
	}
	
	/* Idea of this function is from TextOutputStream documentation.
	 * Note: hasProcessedNewLines will return true when a new line is encountered even if the processing is to do nothing. */
	func processForLogging(fullASCII: Bool = false, newLineProcessing: NewLineProcessing) -> (string: String, hasProcessedNewLines: Bool) {
		var hasProcessedNewLines = false
		let ascii = unicodeScalars.lazy.map{ scalar in
			if Self.newLines.contains(scalar) {
				hasProcessedNewLines = true
				switch newLineProcessing {
					case .none:           return String(scalar)
					case .escapeAsASCII:  return scalar.escaped(asASCII: true)
					case .replace(let r): return r
				}
			} else {
				return scalar.escaped(asASCII: fullASCII)
			}
		}
		return (ascii.joined(separator: ""), hasProcessedNewLines)
	}
	
	private static let newLines = CharacterSet.newlines
	
}
