/*
Copyright 2019 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import Foundation



/* This is from XibLoc. */
extension Scanner {
	
	enum CompatibleScanLocation {
		case int(Int)
		case index(String.Index)
		/** Crashes if the enum contains an index. */
		var intValue: Int {
			guard case let .int(i) = self else {
				fatalError("Asked for the int value but I have an index.")
			}
			return i
		}
		var indexValue: String.Index {
			guard case let .index(i) = self else {
				fatalError("Asked for the index value but I have an int.")
			}
			return i
		}
	}
	
	var compatibleScanLocation: CompatibleScanLocation {
		get {
#if canImport(Darwin)
			if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
				return .index(currentIndex)
			} else {
				return .int(scanLocation)
			}
#else
			return .index(currentIndex)
#endif
		}
		set {
#if canImport(Darwin)
			if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
				currentIndex = newValue.indexValue
			} else {
				scanLocation = newValue.intValue
			}
#else
			currentIndex = newValue.indexValue
#endif
		}
	}
	
	func xl_scanString(_ string: String) -> String? {
#if canImport(Darwin)
		if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
			return scanString(string)
		} else {
			var result: NSString?
			guard scanString(string, into: &result) else {return nil}
			return result! as String
		}
#else
		return scanString(string)
#endif
	}
	
	func xl_scanCharacter() -> Character? {
#if canImport(Darwin)
		if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
			return scanCharacter()
		} else {
			guard !isAtEnd else {
				return nil
			}
			let utf16 = string.utf16
			let characterStr = utf16[utf16.index(utf16.startIndex, offsetBy: scanLocation)..<utf16.index(utf16.startIndex, offsetBy: scanLocation + 1)]
			var result: NSString?
			guard scanString(String(characterStr)!, into: &result) else {return nil}
			return Character(result! as String)
		}
#else
		return scanCharacter()
#endif
	}
	
	func xl_scanUpToString(_ string: String) -> String? {
#if canImport(Darwin)
		if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
			return scanUpToString(string)
		} else {
			var result: NSString?
			guard scanUpTo(string, into: &result) else {return nil}
			return result! as String
		}
#else
		return scanUpToString(string)
#endif
	}
	
	func xl_scanUpToCharacters(from characterSet: CharacterSet) -> String? {
#if canImport(Darwin)
		if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
			return scanUpToCharacters(from: characterSet)
		} else {
			var result: NSString?
			guard scanUpToCharacters(from: characterSet, into: &result) else {return nil}
			return result! as String
		}
#else
		return scanUpToCharacters(from: characterSet)
#endif
	}
	
	func xl_scanCharacters(from set: CharacterSet) -> String? {
#if canImport(Darwin)
		if #available(macOS 10.15, tvOS 13.0, iOS 13.0, watchOS 6.0, *) {
			return scanCharacters(from: set)
		} else {
			var result: NSString?
			guard scanCharacters(from: set, into: &result) else {return nil}
			return result! as String
		}
#else
		return scanCharacters(from: set)
#endif
	}
	
}
