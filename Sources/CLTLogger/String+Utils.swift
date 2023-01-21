import Foundation



/* From <https://gist.github.com/joshavant/d9a94373ec45a7b5d7e7d98263e46e1e>. */
extension String {
	
	func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> (string: String, hasReplaced: Bool) {
		let c = components(separatedBy: characterSet)
		return (c.joined(separator: replacementString), c.count > 1)
	}
	
	func replacingNewlines(with str: String) -> (string: String, hasReplaced: Bool) {
		return replaceCharactersFromSet(characterSet: .newlines, replacementString: str)
	}
	
}
