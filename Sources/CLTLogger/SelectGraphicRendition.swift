import Foundation



/**
A few links:

- [An answer on Stackoverflow](https://stackoverflow.com/a/33206814)
- [Wikipedia page to SGR](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters)
- [The 4-bits colors table (in Wikipedia)](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
- [The 4-bits colors table (direct image link)](https://i.stack.imgur.com/9UVnC.png)
- [The 8-bits colors table (in Wikipedia)](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit)
- [The 8-bits colors table (direct image link)](https://i.stack.imgur.com/KTSQa.png)
- [List of Terminals supporting True Colors](https://gist.github.com/XVilka/8346728)
- [The ODA Specs](https://en.wikipedia.org/wiki/Open_Document_Architecture#External_links) aka. CCITT T.411-T.424 (equivalent to ISO 8613, but freely downloadable) */
struct SelectGraphicRendition : RawRepresentable, Hashable, CustomStringConvertible {
	
	enum Modifier : RawRepresentable, Hashable, CustomStringConvertible {
		
		/** Reset/Normal – All attributes off */
		case reset
		/** Bold or increased intensity */
		case bold
		/** Decreased intensity – Not widely supported */
		case faint
		/** Italic – Not widely supported – Sometimes treated as inverse (aka. reverse video) */
		case italic
		case underline
		/** Slow blink – less than 150 per minute */
		case slowBlink
		/** Rapid Blink – MS-DOS ANSI.SYS; 150+ per minute – Not widely supported */
		case rapidBlink
		/** Swap foreground and background colors */
		case reverseVideo
		/** Not widely supported – Not in ODA */
		case conceal
		/** Characters legible, but marked for deletion – Not widely supported */
		case crossedOut
		/** Default font */
		case primaryFont
		case alternateFont1
		case alternateFont2
		case alternateFont3
		case alternateFont4
		case alternateFont5
		case alternateFont6
		case alternateFont7
		case alternateFont8
		case alternateFont9
		/** Blackletter font – Hardly ever supported – Not in ODA */
		case fraktur
		/** Bold off not widely supported; double underline hardly ever supported */
		case boldOffOrDoubleUnderline
		/** Neither bold nor faint */
		case normalColorOrIntensity
		case italicAndFrakturOff
		/** Not singly or doubly underlined */
		case underlineOff
		case blinkOff
		/** Proportional spacing – ITU T.61 and T.416; not known to be used on terminals */
		case variableSpacing
		case reverseVideoOff
		/** Reveal – Not in ODA */
		case concealOff
		/** Not crossed out */
		case crossedOutOff
		/**
		Fg to color #0. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #1 in ODA Specs. */
		case fgColorTo4BitBlack
		/**
		Fg to color #1. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #2 in ODA Specs. */
		case fgColorTo4BitRed
		/**
		Fg to color #2. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #3 in ODA Specs. */
		case fgColorTo4BitGreen
		/**
		Fg to color #3. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #4 in ODA Specs. */
		case fgColorTo4BitYellow
		/**
		Fg to color #4. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #5 in ODA Specs. */
		case fgColorTo4BitBlue
		/**
		Fg to color #5. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #6 in ODA Specs. */
		case fgColorTo4BitMagenta
		/**
		Fg to color #6. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #7 in ODA Specs. */
		case fgColorTo4BitCyan
		/**
		Fg to color #7. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #0 in ODA Specs. */
		case fgColorTo4BitWhite
		case fgColorToImplementationDefined
		case fgColorToTransparent
		case fgColorToRGB(red: UInt8, green: UInt8, blue: UInt8)
		/* Note: For ODA formats, I assumed color value type is UInt8 */
		case fgColorToRGBUsingODAFormat(red: UInt8?, green: UInt8?, blue: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		case fgColorToCMYUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		case fgColorToCMYKUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, black: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** See the [8-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) */
		case fgColorTo256PaletteValue(UInt8)
		/**
		Same as `fgColorTo256PaletteValue`, but using ODA format, which uses a
		colon instead of a semicolon for the separator. See the [ODA Specs](https://en.wikipedia.org/wiki/Open_Document_Architecture#External_links)
		aka. CCITT T.411-T.424 (equivalent to ISO 8613, but freely downloadable). */
		case fgColorTo256PaletteValueODAFormat(UInt8)
		
		/** Implementation defined (according to standard) – Not in ODA */
		case fgColorToDefault
		
		/**
		Bg to color #0. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #1 in ODA Specs. */
		case bgColorTo4BitBlack
		/**
		Bg to color #1. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #2 in ODA Specs. */
		case bgColorTo4BitRed
		/**
		Bg to color #2. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #3 in ODA Specs. */
		case bgColorTo4BitGreen
		/**
		Bg to color #3. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #4 in ODA Specs. */
		case bgColorTo4BitYellow
		/**
		Bg to color #4. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #5 in ODA Specs. */
		case bgColorTo4BitBlue
		/**
		Bg to color #5. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #6 in ODA Specs. */
		case bgColorTo4BitMagenta
		/**
		Bg to color #6. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #7 in ODA Specs. */
		case bgColorTo4BitCyan
		/**
		Bg to color #7. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		- Note: It’s color index #0 in ODA Specs. */
		case bgColorTo4BitWhite
		case bgColorToTransparent
		case bgColorToRGB(red: UInt8, green: UInt8, blue: UInt8)
		/* Note: For ODA formats, I assumed color value type is UInt8 */
		case bgColorToRGBUsingODAFormat(red: UInt8?, green: UInt8?, blue: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		case bgColorToCMYUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		case bgColorToCMYKUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, black: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** See the [8-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit) */
		case bgColorTo256PaletteValue(UInt8)
		/**
		Same as `bgColorTo256PaletteValue`, but using ODA format, which uses a
		colon instead of a semicolon for the separator. See the [ODA Specs](https://en.wikipedia.org/wiki/Open_Document_Architecture#External_links)
		aka. CCITT T.411-T.424 (equivalent to ISO 8613, but freely downloadable). */
		case bgColorTo256PaletteValueODAFormat(UInt8)
		
		/** Implementation defined (according to standard) – Not in ODA */
		case bgColorToDefault
		
		/** T.61 and T.416 */
		case variableSpacingOff
		
		/* ********* All cases below are not in ODA ********* */
		
		case framed
		case encircled
		case overlined
		case framedOrEncircledOff
		case overlinedOff
		
		/** Not in standard */
		case underlineColorToRGB(red: UInt8, green: UInt8, blue: UInt8)
		/** Not in standard */
		case underlineColorTo256PaletteValue(UInt8)
		/** Not in standard */
		case underlineColorToDefault
		
		/** Line on right side – Hardly ever supported */
		case ideogramUnderline
		/** Double-line on right side – Hardly ever supported */
		case ideogramDoubleUnderline
		/** Line on left side – Hardly ever supported */
		case ideogramOverline
		/** Double-line on left side – Hardly ever supported */
		case ideogramDoubleOverline
		/** Hardly ever supported */
		case ideogramStressMarking
		/** Turn off all ideogram modifiers */
		case ideogramFocusOff
		
		/** Implemented only in mintty */
		case superscript
		/** Implemented only in mintty */
		case `subscript`
		/** Implemented only in mintty */
		case subOrSubScriptOff
		
		/**
		Fg to bright color #0. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitBlack` + `.bold` IIUC). */
		case fgColorTo4BitBrightBlack
		/**
		Fg to bright color #1. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitRed` + `.bold` IIUC). */
		case fgColorTo4BitBrightRed
		/**
		Fg to bright color #2. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitGreen` + `.bold` IIUC). */
		case fgColorTo4BitBrightGreen
		/**
		Fg to bright color #3. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitYellow` + `.bold` IIUC). */
		case fgColorTo4BitBrightYellow
		/**
		Fg to bright color #4. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitBlue` + `.bold` IIUC). */
		case fgColorTo4BitBrightBlue
		/**
		Fg to bright color #5. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitMagenta` + `.bold` IIUC). */
		case fgColorTo4BitBrightMagenta
		/**
		Fg to bright color #6. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitCyan` + `.bold` IIUC). */
		case fgColorTo4BitBrightCyan
		/**
		Fg to bright color #7. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.fgColorTo4BitWhite` + `.bold` IIUC). */
		case fgColorTo4BitBrightWhite
		
		/**
		Bg to bright color #0. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitBlack` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightBlack
		/**
		Bg to bright color #1. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitRed` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightRed
		/**
		Bg to bright color #2. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitGreen` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightGreen
		/**
		Bg to bright color #3. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitYellow` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightYellow
		/**
		Bg to bright color #4. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitBlue` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightBlue
		/**
		Bg to bright color #5. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitMagenta` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightMagenta
		/**
		Bg to bright color #6. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitCyan` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightCyan
		/**
		Bg to bright color #7. See the [4-bits colors table](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)
		
		Not standard (equivalent to `.bgColorTo4BitWhite` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightWhite
		
		struct ColorSpaceInfo {
			
			/**
			- Note: I did not know the type for this one, so I assumed `Int`. */
			var colorSpaceId: Int?
			var colorSpaceTolerance: Int?
			var colorSpaceAssociatedWithTolerance: ColorSpaceForTolerance?
			
			var colorSpaceIdAsString: String? {colorSpaceId.flatMap{ "\($0)" }}
			var colorSpaceToleranceAsString: String? {colorSpaceTolerance.flatMap{ "\($0)" }}
			var colorSpaceAssociatedWithToleranceAsString: String? {colorSpaceAssociatedWithTolerance.flatMap{ "\($0.rawValue)" }}
			
			enum ColorSpaceForTolerance : Int {
				case cieluv = 0
				case cielab = 1
			}
			
		}
		
		public var rawValue: String {
			switch self {
				case .reset: return "0"
				case .bold: return "1"
				case .faint: return "2"
				case .italic: return "3"
				case .underline: return "4"
				case .slowBlink: return "5"
				case .rapidBlink: return "6"
				case .reverseVideo: return "7"
				case .conceal: return "8"
				case .crossedOut: return "9"
				case .primaryFont: return "10"
				case .alternateFont1: return "11"
				case .alternateFont2: return "12"
				case .alternateFont3: return "13"
				case .alternateFont4: return "14"
				case .alternateFont5: return "15"
				case .alternateFont6: return "16"
				case .alternateFont7: return "17"
				case .alternateFont8: return "18"
				case .alternateFont9: return "19"
				case .fraktur: return "20"
				case .boldOffOrDoubleUnderline: return "21"
				case .normalColorOrIntensity: return "22"
				case .italicAndFrakturOff: return "23"
				case .underlineOff: return "24"
				case .blinkOff: return "25"
				case .variableSpacing: return "26"
				case .reverseVideoOff: return "27"
				case .concealOff: return "28"
				case .crossedOutOff: return "29"
				case .fgColorTo4BitBlack: return "30"
				case .fgColorTo4BitRed: return "31"
				case .fgColorTo4BitGreen: return "32"
				case .fgColorTo4BitYellow: return "33"
				case .fgColorTo4BitBlue: return "34"
				case .fgColorTo4BitMagenta: return "35"
				case .fgColorTo4BitCyan: return "36"
				case .fgColorTo4BitWhite: return "37"
				case .fgColorToImplementationDefined: return "38:0"
				case .fgColorToTransparent: return "38:1"
				case .fgColorToRGB(red: let red, green: let green, blue: let blue): return "38;2;\(red);\(green);\(blue)"
				case .fgColorToRGBUsingODAFormat(red: let red, green: let green, blue: let blue, colorSpaceInfo: let colorSpaceInfo): return "38:2:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(red)):\(optionalIntAsString(green)):\(optionalIntAsString(blue))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .fgColorToCMYUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, colorSpaceInfo: let colorSpaceInfo): return "38:3:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .fgColorToCMYKUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, black: let black, colorSpaceInfo: let colorSpaceInfo): return "38:3:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow)):\(optionalIntAsString(black)):\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .fgColorTo256PaletteValue(let value): return "38;5;\(value)"
				case .fgColorTo256PaletteValueODAFormat(let value): return "38:5:\(value)"
				case .fgColorToDefault: return "39"
				case .bgColorTo4BitBlack: return "40"
				case .bgColorTo4BitRed: return "41"
				case .bgColorTo4BitGreen: return "42"
				case .bgColorTo4BitYellow: return "43"
				case .bgColorTo4BitBlue: return "44"
				case .bgColorTo4BitMagenta: return "45"
				case .bgColorTo4BitCyan: return "46"
				case .bgColorTo4BitWhite: return "47"
				case .bgColorToTransparent: return "48:1"
				case .bgColorToRGB(red: let red, green: let green, blue: let blue): return "48;2;\(red);\(green);\(blue)"
				case .bgColorToRGBUsingODAFormat(red: let red, green: let green, blue: let blue, colorSpaceInfo: let colorSpaceInfo): return "48:2:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(red)):\(optionalIntAsString(green)):\(optionalIntAsString(blue))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .bgColorToCMYUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, colorSpaceInfo: let colorSpaceInfo): return "48:3:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .bgColorToCMYKUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, black: let black, colorSpaceInfo: let colorSpaceInfo): return "48:3:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow)):\(optionalIntAsString(black)):\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .bgColorTo256PaletteValue(let value): return "48;5;\(value)"
				case .bgColorTo256PaletteValueODAFormat(let value): return "48:5:\(value)"
				case .bgColorToDefault: return "49"
				case .variableSpacingOff: return "50"
				case .framed: return "51"
				case .encircled: return "52"
				case .overlined: return "53"
				case .framedOrEncircledOff: return "54"
				case .overlinedOff: return "55"
				case .underlineColorToRGB(red: let red, green: let green, blue: let blue): return "58;2;\(red);\(green);\(blue)"
				case .underlineColorTo256PaletteValue(let value): return "58;5;\(value)"
				case .underlineColorToDefault: return "59"
				case .ideogramUnderline: return "60"
				case .ideogramDoubleUnderline: return "61"
				case .ideogramOverline: return "62"
				case .ideogramDoubleOverline: return "63"
				case .ideogramStressMarking: return "64"
				case .ideogramFocusOff: return "65"
				case .superscript: return "73"
				case .`subscript`: return "74"
				case .subOrSubScriptOff: return "75"
				case .fgColorTo4BitBrightBlack: return "90"
				case .fgColorTo4BitBrightRed: return "91"
				case .fgColorTo4BitBrightGreen: return "92"
				case .fgColorTo4BitBrightYellow: return "93"
				case .fgColorTo4BitBrightBlue: return "94"
				case .fgColorTo4BitBrightMagenta: return "95"
				case .fgColorTo4BitBrightCyan: return "96"
				case .fgColorTo4BitBrightWhite: return "97"
				case .bgColorTo4BitBrightBlack: return "100"
				case .bgColorTo4BitBrightRed: return "101"
				case .bgColorTo4BitBrightGreen: return "102"
				case .bgColorTo4BitBrightYellow: return "103"
				case .bgColorTo4BitBrightBlue: return "104"
				case .bgColorTo4BitBrightMagenta: return "105"
				case .bgColorTo4BitBrightCyan: return "106"
				case .bgColorTo4BitBrightWhite: return "107"
			}
		}
		
		public init?(rawValue: String) {
			#warning("TODO")
			fatalError("TODO")
		}
		
		var description: String {
			/* TODO maybe one day: switch on self and describe modifier? */
			return "SGR Modifier <\(rawValue)>"
		}
		
		private func optionalIntAsString(_ v: UInt8?) -> String {
			return v.flatMap{ String($0) } ?? ""
		}
		
	}
	
	var modifiers: [Modifier]
	
	var rawValue: String {
		return "\u{1B}[\(modifiers.map{ $0.rawValue }.joined(separator: ";"))m"
	}
	
	init(modifiers: [Modifier]) {
		self.modifiers = modifiers
	}
	
	init?(rawValue: String) {
		#warning("TODO")
		fatalError("TODO")
	}
	
	var description: String {
		/* TODO maybe one day: describe SGR? */
		return "SGR <\(rawValue)>"
	}
	
}
