import Foundation



/**
 A struct representing one Select Graphic Rendition (SGR).
 
 A few links:
 
 - [An answer on Stackoverflow](<https://stackoverflow.com/a/33206814>);
 - [Wikipedia page to SGR](<https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters>);
 - [The 4-bits colors table (in Wikipedia)](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>);
 - [The 4-bits colors table (direct image link)](<https://i.stack.imgur.com/9UVnC.png>);
 - [The 8-bits colors table (in Wikipedia)](<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>);
 - [The 8-bits colors table (direct image link)](<https://i.stack.imgur.com/KTSQa.png>);
 - [List of Terminals supporting True Colors](<https://gist.github.com/XVilka/8346728>);
 - [The ODA Specs](<https://en.wikipedia.org/wiki/Open_Document_Architecture#External_links>) aka. CCITT T.411-T.424 (equivalent to ISO 8613, but freely downloadable). */
public struct SGR : RawRepresentable, Hashable, CustomStringConvertible {
	
	public enum Modifier : RawRepresentable, Hashable, CustomStringConvertible {
		
		/** Reset/Normal -- All attributes off. */
		case reset
		/** Bold or increased intensity. */
		case bold
		/** Decreased intensity -- Not widely supported. */
		case faint
		/** Italic -- Not widely supported -- Sometimes treated as inverse (aka. reverse video). */
		case italic
		case underline
		/** Slow blink -- less than 150 per minute. */
		case slowBlink
		/** Rapid Blink -- MS-DOS ANSI.SYS; 150+ per minute -- Not widely supported. */
		case rapidBlink
		/** Swap foreground and background colors. */
		case reverseVideo
		/** Not widely supported -- Not in ODA. */
		case conceal
		/** Characters legible, but marked for deletion -- Not widely supported. */
		case crossedOut
		/** Default font. */
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
		/** Blackletter font -- Hardly ever supported -- Not in ODA. */
		case fraktur
		/** Bold off not widely supported; double underline hardly ever supported. */
		case boldOffOrDoubleUnderline
		/** Neither bold nor faint. */
		case normalColorOrIntensity
		case italicAndFrakturOff
		/** Not singly or doubly underlined. */
		case underlineOff
		case blinkOff
		/** Proportional spacing -- ITU T.61 and T.416; not known to be used on terminals. */
		case variableSpacing
		case reverseVideoOff
		/** Reveal -- Not in ODA. */
		case concealOff
		/** Not crossed out. */
		case crossedOutOff
		/**
		 Fg to color #0. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #1 in ODA Specs. */
		case fgColorTo4BitBlack
		/**
		 Fg to color #1. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #2 in ODA Specs. */
		case fgColorTo4BitRed
		/**
		 Fg to color #2. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #3 in ODA Specs. */
		case fgColorTo4BitGreen
		/**
		 Fg to color #3. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #4 in ODA Specs. */
		case fgColorTo4BitYellow
		/**
		 Fg to color #4. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #5 in ODA Specs. */
		case fgColorTo4BitBlue
		/**
		 Fg to color #5. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #6 in ODA Specs. */
		case fgColorTo4BitMagenta
		/**
		 Fg to color #6. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #7 in ODA Specs. */
		case fgColorTo4BitCyan
		/**
		 Fg to color #7. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #0 in ODA Specs. */
		case fgColorTo4BitWhite
		case fgColorToImplementationDefined
		case fgColorToTransparent
		case fgColorToRGB(red: UInt8, green: UInt8, blue: UInt8)
		/** - Note: I assumed color value type is UInt8 for ODA format. */
		case fgColorToRGBUsingODAFormat(red: UInt8?, green: UInt8?, blue: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** - Note: I assumed color value type is UInt8 for ODA format. */
		case fgColorToCMYUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** - Note: I assumed color value type is UInt8 for ODA format. */
		case fgColorToCMYKUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, black: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** See the [8-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>). */
		case fgColorTo256PaletteValue(UInt8)
		/**
		 Same as `fgColorTo256PaletteValue`, but using ODA format, which uses a colon instead of a semicolon for the separator.
		 See the [ODA Specs](<https://en.wikipedia.org/wiki/Open_Document_Architecture#External_links>) aka. CCITT T.411-T.424 (equivalent to ISO 8613, but freely downloadable). */
		case fgColorTo256PaletteValueODAFormat(UInt8?)
		
		/** Implementation defined (according to standard) -- Not in ODA. */
		case fgColorToDefault
		
		/**
		 Bg to color #0. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #1 in ODA Specs. */
		case bgColorTo4BitBlack
		/**
		 Bg to color #1. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #2 in ODA Specs. */
		case bgColorTo4BitRed
		/**
		 Bg to color #2. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #3 in ODA Specs. */
		case bgColorTo4BitGreen
		/**
		 Bg to color #3. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #4 in ODA Specs. */
		case bgColorTo4BitYellow
		/**
		 Bg to color #4. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #5 in ODA Specs. */
		case bgColorTo4BitBlue
		/**
		 Bg to color #5. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #6 in ODA Specs. */
		case bgColorTo4BitMagenta
		/**
		 Bg to color #6. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #7 in ODA Specs. */
		case bgColorTo4BitCyan
		/**
		 Bg to color #7. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 - Note: It’s color index #0 in ODA Specs. */
		case bgColorTo4BitWhite
		case bgColorToTransparent
		case bgColorToRGB(red: UInt8, green: UInt8, blue: UInt8)
		/** - Note: I assumed color value type is UInt8 for ODA format. */
		case bgColorToRGBUsingODAFormat(red: UInt8?, green: UInt8?, blue: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** - Note: I assumed color value type is UInt8 for ODA format. */
		case bgColorToCMYUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** - Note: I assumed color value type is UInt8 for ODA format. */
		case bgColorToCMYKUsingODAFormat(cyan: UInt8?, magenta: UInt8?, yellow: UInt8?, black: UInt8?, colorSpaceInfo: ColorSpaceInfo?)
		/** See the [8-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>). */
		case bgColorTo256PaletteValue(UInt8)
		/**
		 Same as `bgColorTo256PaletteValue`, but using ODA format, which uses a colon instead of a semicolon for the separator.
		 See the [ODA Specs](<https://en.wikipedia.org/wiki/Open_Document_Architecture#External_links>) aka. CCITT T.411-T.424 (equivalent to ISO 8613, but freely downloadable). */
		case bgColorTo256PaletteValueODAFormat(UInt8?)
		
		/** Implementation defined (according to standard) -- Not in ODA. */
		case bgColorToDefault
		
		/** T.61 and T.416. */
		case variableSpacingOff
		
		/* ********* All cases below are not in ODA. ********* */
		
		case framed
		case encircled
		case overlined
		case framedOrEncircledOff
		case overlinedOff
		
		/** Not in standard. */
		case underlineColorToRGB(red: UInt8, green: UInt8, blue: UInt8)
		/** Not in standard. */
		case underlineColorTo256PaletteValue(UInt8)
		/** Not in standard. */
		case underlineColorToDefault
		
		/** Line on right side -- Hardly ever supported. */
		case ideogramUnderline
		/** Double-line on right side -- Hardly ever supported. */
		case ideogramDoubleUnderline
		/** Line on left side -- Hardly ever supported. */
		case ideogramOverline
		/** Double-line on left side -- Hardly ever supported. */
		case ideogramDoubleOverline
		/** Hardly ever supported. */
		case ideogramStressMarking
		/** Turn off all ideogram modifiers. */
		case ideogramFocusOff
		
		/** Implemented only in mintty. */
		case superscript
		/** Implemented only in mintty. */
		case `subscript`
		/** Implemented only in mintty. */
		case subOrSubScriptOff
		
		/**
		 Fg to bright color #0. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitBlack` + `.bold` IIUC). */
		case fgColorTo4BitBrightBlack
		/**
		 Fg to bright color #1. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitRed` + `.bold` IIUC). */
		case fgColorTo4BitBrightRed
		/**
		 Fg to bright color #2. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitGreen` + `.bold` IIUC). */
		case fgColorTo4BitBrightGreen
		/**
		 Fg to bright color #3. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitYellow` + `.bold` IIUC). */
		case fgColorTo4BitBrightYellow
		/**
		 Fg to bright color #4. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitBlue` + `.bold` IIUC). */
		case fgColorTo4BitBrightBlue
		/**
		 Fg to bright color #5. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitMagenta` + `.bold` IIUC). */
		case fgColorTo4BitBrightMagenta
		/**
		 Fg to bright color #6. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitCyan` + `.bold` IIUC). */
		case fgColorTo4BitBrightCyan
		/**
		 Fg to bright color #7. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.fgColorTo4BitWhite` + `.bold` IIUC). */
		case fgColorTo4BitBrightWhite
		
		/**
		 Bg to bright color #0. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitBlack` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightBlack
		/**
		 Bg to bright color #1. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitRed` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightRed
		/**
		 Bg to bright color #2. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitGreen` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightGreen
		/**
		 Bg to bright color #3. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitYellow` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightYellow
		/**
		 Bg to bright color #4. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitBlue` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightBlue
		/**
		 Bg to bright color #5. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitMagenta` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightMagenta
		/**
		 Bg to bright color #6. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitCyan` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightCyan
		/**
		 Bg to bright color #7. See the [4-bits colors table](<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>).
		 
		 Not standard (equivalent to `.bgColorTo4BitWhite` + `.bold` + `.reverseVideo` IIUC). */
		case bgColorTo4BitBrightWhite
		
		public struct ColorSpaceInfo {
			
			/**
			 - Note: I did not know the type for this one, so I assumed `Int`. */
			public var colorSpaceId: Int?
			public var colorSpaceTolerance: Int?
			public var colorSpaceAssociatedWithTolerance: ColorSpaceForTolerance?
			
			public var colorSpaceIdAsString: String? {colorSpaceId.flatMap{ "\($0)" }}
			public var colorSpaceToleranceAsString: String? {colorSpaceTolerance.flatMap{ "\($0)" }}
			public var colorSpaceAssociatedWithToleranceAsString: String? {colorSpaceAssociatedWithTolerance.flatMap{ "\($0.rawValue)" }}
			
			public enum ColorSpaceForTolerance : Int {
				case cieluv = 0
				case cielab = 1
			}
			
			public init(colorSpaceId: Int?, colorSpaceTolerance: Int?, colorSpaceAssociatedWithTolerance: ColorSpaceForTolerance?) {
				self.colorSpaceId = colorSpaceId
				self.colorSpaceTolerance = colorSpaceTolerance
				self.colorSpaceAssociatedWithTolerance = colorSpaceAssociatedWithTolerance
			}
			
			init?(param2: Int?, param7: Int?, param8: Int?) {
				switch param8 {
					case nil: colorSpaceAssociatedWithTolerance = nil
					case 0?:  colorSpaceAssociatedWithTolerance = .cieluv
					case 1?:  colorSpaceAssociatedWithTolerance = .cielab
					default:  return nil
				}
				colorSpaceId = param2
				colorSpaceTolerance = param7
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
				case .fgColorToRGB(red: let red, green: let green, blue: let blue): return "38\(Self.separatorChar)2\(Self.separatorChar)\(red)\(Self.separatorChar)\(green)\(Self.separatorChar)\(blue)"
				case .fgColorToRGBUsingODAFormat(red: let red, green: let green, blue: let blue, colorSpaceInfo: let colorSpaceInfo): return "38:2:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(red)):\(optionalIntAsString(green)):\(optionalIntAsString(blue))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .fgColorToCMYUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, colorSpaceInfo: let colorSpaceInfo): return "38:3:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .fgColorToCMYKUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, black: let black, colorSpaceInfo: let colorSpaceInfo): return "38:4:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow)):\(optionalIntAsString(black)):\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .fgColorTo256PaletteValue(let value): return "38\(Self.separatorChar)5\(Self.separatorChar)\(value)"
				case .fgColorTo256PaletteValueODAFormat(let value): return "38:5:\(optionalIntAsString(value))"
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
				case .bgColorToRGB(red: let red, green: let green, blue: let blue): return "48\(Self.separatorChar)2\(Self.separatorChar)\(red)\(Self.separatorChar)\(green)\(Self.separatorChar)\(blue)"
				case .bgColorToRGBUsingODAFormat(red: let red, green: let green, blue: let blue, colorSpaceInfo: let colorSpaceInfo): return "48:2:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(red)):\(optionalIntAsString(green)):\(optionalIntAsString(blue))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .bgColorToCMYUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, colorSpaceInfo: let colorSpaceInfo): return "48:3:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow))::\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .bgColorToCMYKUsingODAFormat(cyan: let cyan, magenta: let magenta, yellow: let yellow, black: let black, colorSpaceInfo: let colorSpaceInfo): return "48:4:\(colorSpaceInfo?.colorSpaceIdAsString ?? ""):\(optionalIntAsString(cyan)):\(optionalIntAsString(magenta)):\(optionalIntAsString(yellow)):\(optionalIntAsString(black)):\(colorSpaceInfo?.colorSpaceToleranceAsString ?? ""):\(colorSpaceInfo?.colorSpaceAssociatedWithToleranceAsString ?? "")"
				case .bgColorTo256PaletteValue(let value): return "48\(Self.separatorChar)5\(Self.separatorChar)\(value)"
				case .bgColorTo256PaletteValueODAFormat(let value): return "48:5:\(optionalIntAsString(value))"
				case .bgColorToDefault: return "49"
				case .variableSpacingOff: return "50"
				case .framed: return "51"
				case .encircled: return "52"
				case .overlined: return "53"
				case .framedOrEncircledOff: return "54"
				case .overlinedOff: return "55"
				case .underlineColorToRGB(red: let red, green: let green, blue: let blue): return "58\(Self.separatorChar)2\(Self.separatorChar)\(red)\(Self.separatorChar)\(green)\(Self.separatorChar)\(blue)"
				case .underlineColorTo256PaletteValue(let value): return "58\(Self.separatorChar)5\(Self.separatorChar)\(value)"
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
			let s = Scanner(forParsing: rawValue)
			
			self.init(scanner: s)
			
			guard s.isAtEnd else {
				return nil
			}
		}
		
		/* Note: This init probably has terrible perfs. */
		init?(scanner: Scanner) {
			struct DummyError : Error {}
			let originalScannerIndex = scanner.currentIndex
			do {
				enum ColorDestination : String {
					case fg = "38"
					case bg = "48"
					case ul = "58"
				}
				let token = scanner.scanUpToCharacters(from: CharacterSet(charactersIn: String(Self.separatorChar) + String(SGR.sgrEndChar))) ?? ""
				if token.contains(":") {
					/* Let’s process the special ODA cases. */
					let subScanner = Scanner(forParsing: token)
					let subToken = subScanner.scanUpToString(":") ?? ""
					_ = subScanner.scanString(":")! /* !: The string contains a colon, so the scan cannot fail. */
					
					let isFgColor: Bool
					switch subToken {
						case "38": isFgColor = true
						case "48": isFgColor = false
						default:
							/* We only consider the 38 and 48 cases, which should be the only valid ones, and the only one we allow building.
							 * Note however, it might be possible to get the 58 case too (underline color), though because it is not part of the ODA it shouldn’t be valid with this notation. */
							throw DummyError()
					}
					let colorFormat = subScanner.scanUpToString(":") ?? ""
					switch colorFormat {
						case "0", "":
							guard isFgColor, subScanner.isAtEnd else {
								throw DummyError()
							}
							self = .fgColorToImplementationDefined
							return
							
						case "1":
							guard subScanner.isAtEnd else {
								throw DummyError()
							}
							self = (isFgColor ? .fgColorToTransparent : .bgColorToTransparent)
							return
							
						default: (/*nop!*/)
					}
					
					func scanParam() throws -> Int? {
						if subScanner.isAtEnd {return nil}
						else {
							guard subScanner.scanString(":") != nil else {
								throw DummyError()
							}
							guard let str = subScanner.scanUpToString(":") else {
								return nil
							}
							/* We assume “+1” is a valid value. */
							guard let v = Int(str, radix: 10) else {
								throw DummyError()
							}
							return v
						}
					}
					
					func uint8(_ i: Int?) throws -> UInt8? {
						guard let i = i else {return nil}
						guard i >= 0, i <= UInt8.max else {
							throw DummyError()
						}
						return UInt8(i)
					}
					
					let param2 = try scanParam()
					if colorFormat == "5" {
						guard subScanner.isAtEnd else {
							throw DummyError()
						}
						let v = try uint8(param2)
						self = (isFgColor ? .fgColorTo256PaletteValueODAFormat(v) : .bgColorTo256PaletteValueODAFormat(v))
						return
					}
					
					let param3 = try scanParam()
					let param4 = try scanParam()
					let param5 = try scanParam()
					let param6 = try scanParam()
					let param7 = try scanParam()
					let param8 = try scanParam()
					guard subScanner.isAtEnd else {throw DummyError()}
					guard let colorSpaceInfo = ColorSpaceInfo(param2: param2, param7: param7, param8: param8) else {
						throw DummyError()
					}
					switch colorFormat {
						case "2":
							let r = try uint8(param3)
							let g = try uint8(param4)
							let b = try uint8(param5)
							self = (isFgColor ?
								.fgColorToRGBUsingODAFormat(red: r, green: g, blue: b, colorSpaceInfo: colorSpaceInfo) :
								.bgColorToRGBUsingODAFormat(red: r, green: g, blue: b, colorSpaceInfo: colorSpaceInfo)
							)
							return
							
						case "3": ()
							let c = try uint8(param3)
							let m = try uint8(param4)
							let y = try uint8(param5)
							self = (isFgColor ?
								.fgColorToCMYUsingODAFormat(cyan: c, magenta: m, yellow: y, colorSpaceInfo: colorSpaceInfo) :
								.bgColorToCMYUsingODAFormat(cyan: c, magenta: m, yellow: y, colorSpaceInfo: colorSpaceInfo)
							)
							return
							
						case "4": ()
							let c = try uint8(param3)
							let m = try uint8(param4)
							let y = try uint8(param5)
							let k = try uint8(param6)
							self = (isFgColor ?
								.fgColorToCMYKUsingODAFormat(cyan: c, magenta: m, yellow: y, black: k, colorSpaceInfo: colorSpaceInfo) :
								.bgColorToCMYKUsingODAFormat(cyan: c, magenta: m, yellow: y, black: k, colorSpaceInfo: colorSpaceInfo)
							)
							return
							
						default:
							throw DummyError()
					}
				}
				if let colorDestination = ColorDestination(rawValue: token) {
					guard
						scanner.scanCharacter() == Self.separatorChar,
						let colorType = scanner.scanCharacter(),
						scanner.scanCharacter() == Self.separatorChar
					else {
						throw DummyError()
					}
					func uint8(_ s: String) throws -> UInt8 {
						guard
							s.rangeOfCharacter(from: Self.numCharset.inverted) == nil, /* Prevents “+2” from being parsed. */
							let i = Int(s, radix: 10),
							i >= 0, i <= UInt8.max
						else {
							throw DummyError()
						}
						return UInt8(i)
					}
					switch colorType {
						case "2":
							/* Wikipedia says empty values are treated as 0.
							 * But Terminal for instance does not seem to know that.
							 * We don’t care, we do like Wikipedia says. */
							let r = try uint8(scanner.scanUpToString(String(Self.separatorChar)) ?? "0")
							guard scanner.scanCharacter() == Self.separatorChar else {throw DummyError()}
							let g = try uint8(scanner.scanUpToString(String(Self.separatorChar)) ?? "0")
							guard scanner.scanCharacter() == Self.separatorChar else {throw DummyError()}
							let b = try uint8(scanner.scanUpToString(String(Self.separatorChar)) ?? "0")
							switch colorDestination {
								case .fg: self = .fgColorToRGB(red: r, green: g, blue: b); return
								case .bg: self = .bgColorToRGB(red: r, green: g, blue: b); return
								case .ul: self = .underlineColorToRGB(red: r, green: g, blue: b); return
							}
							
						case "5":
							let v = try uint8(scanner.scanUpToString(String(Self.separatorChar)) ?? "0")
							switch colorDestination {
								case .fg: self = .fgColorTo256PaletteValue(v); return
								case .bg: self = .bgColorTo256PaletteValue(v); return
								case .ul: self = .underlineColorTo256PaletteValue(v); return
							}
							
						default:
							throw DummyError()
					}
				}
				switch token {
					case "0", "": self = .reset
					case "1": self = .bold
					case "2": self = .faint
					case "3": self = .italic
					case "4": self = .underline
					case "5": self = .slowBlink
					case "6": self = .rapidBlink
					case "7": self = .reverseVideo
					case "8": self = .conceal
					case "9": self = .crossedOut
					case "10": self = .primaryFont
					case "11": self = .alternateFont1
					case "12": self = .alternateFont2
					case "13": self = .alternateFont3
					case "14": self = .alternateFont4
					case "15": self = .alternateFont5
					case "16": self = .alternateFont6
					case "17": self = .alternateFont7
					case "18": self = .alternateFont8
					case "19": self = .alternateFont9
					case "20": self = .fraktur
					case "21": self = .boldOffOrDoubleUnderline
					case "22": self = .normalColorOrIntensity
					case "23": self = .italicAndFrakturOff
					case "24": self = .underlineOff
					case "25": self = .blinkOff
					case "26": self = .variableSpacing
					case "27": self = .reverseVideoOff
					case "28": self = .concealOff
					case "29": self = .crossedOutOff
					case "30": self = .fgColorTo4BitBlack
					case "31": self = .fgColorTo4BitRed
					case "32": self = .fgColorTo4BitGreen
					case "33": self = .fgColorTo4BitYellow
					case "34": self = .fgColorTo4BitBlue
					case "35": self = .fgColorTo4BitMagenta
					case "36": self = .fgColorTo4BitCyan
					case "37": self = .fgColorTo4BitWhite
					case "39": self = .fgColorToDefault
					case "40": self = .bgColorTo4BitBlack
					case "41": self = .bgColorTo4BitRed
					case "42": self = .bgColorTo4BitGreen
					case "43": self = .bgColorTo4BitYellow
					case "44": self = .bgColorTo4BitBlue
					case "45": self = .bgColorTo4BitMagenta
					case "46": self = .bgColorTo4BitCyan
					case "47": self = .bgColorTo4BitWhite
					case "49": self = .bgColorToDefault
					case "50": self = .variableSpacingOff
					case "51": self = .framed
					case "52": self = .encircled
					case "53": self = .overlined
					case "54": self = .framedOrEncircledOff
					case "55": self = .overlinedOff
					case "59": self = .underlineColorToDefault
					case "60": self = .ideogramUnderline
					case "61": self = .ideogramDoubleUnderline
					case "62": self = .ideogramOverline
					case "63": self = .ideogramDoubleOverline
					case "64": self = .ideogramStressMarking
					case "65": self = .ideogramFocusOff
					case "73": self = .superscript
					case "74": self = .`subscript`
					case "75": self = .subOrSubScriptOff
					case "90": self = .fgColorTo4BitBrightBlack
					case "91": self = .fgColorTo4BitBrightRed
					case "92": self = .fgColorTo4BitBrightGreen
					case "93": self = .fgColorTo4BitBrightYellow
					case "94": self = .fgColorTo4BitBrightBlue
					case "95": self = .fgColorTo4BitBrightMagenta
					case "96": self = .fgColorTo4BitBrightCyan
					case "97": self = .fgColorTo4BitBrightWhite
					case "100": self = .bgColorTo4BitBrightBlack
					case "101": self = .bgColorTo4BitBrightRed
					case "102": self = .bgColorTo4BitBrightGreen
					case "103": self = .bgColorTo4BitBrightYellow
					case "104": self = .bgColorTo4BitBrightBlue
					case "105": self = .bgColorTo4BitBrightMagenta
					case "106": self = .bgColorTo4BitBrightCyan
					case "107": self = .bgColorTo4BitBrightWhite
					default: throw DummyError()
				}
			} catch {
				scanner.currentIndex = originalScannerIndex
				return nil
			}
		}
		
		public var description: String {
			return "SGR.Modifier<\(rawValue)>"
		}
		
		static let separatorChar = Character(";")
		private static let numCharset = CharacterSet(charactersIn: "0123456789")
		
		private func optionalIntAsString(_ v: UInt8?) -> String {
			return v.flatMap{ String($0) } ?? ""
		}
		
	}
	
	public static var reset: SGR {
		return SGR(.reset)
	}
	
	public var modifiers: [Modifier]
	
	public var rawValue: String {
		return String(Self.escapeChar) + String(Self.csiChar) + "\(modifiers.map{ $0.rawValue }.joined(separator: String(Modifier.separatorChar)))" + String(Self.sgrEndChar)
	}
	
	public init(_ modifiers: Modifier...) {
		self.modifiers = modifiers
	}
	
	public init(_ modifiers: [Modifier]) {
		self.modifiers = modifiers
	}
	
	public init?(rawValue: String) {
		let s = Scanner(forParsing: rawValue)
		
		self.init(scanner: s)
		
		guard s.isAtEnd else {
			return nil
		}
	}
	
	/* For symetry w/ SGR.Modifier init, but not really needed, at least for now. */
	init?(scanner: Scanner) {
		struct DummyError : Error {}
		let originalScannerIndex = scanner.currentIndex
		do {
			guard
				scanner.scanCharacter() == Self.escapeChar,
				scanner.scanCharacter() == Self.csiChar
			else {
				/* Not a CSI. */
				throw DummyError()
			}
			
			let csiContent = scanner.scanUpToCharacters(from: Self.possibleFinalByte) ?? ""
			guard scanner.scanCharacter() == Self.sgrEndChar else {
				/* Not an SGR. */
				throw DummyError()
			}
			
			modifiers = [Modifier]()
			
			let contentScanner = Scanner(forParsing: csiContent)
			while let modifier = Modifier(scanner: contentScanner) {
				modifiers.append(modifier)
				guard !contentScanner.isAtEnd else {break}
				/* A modifier has been parsed.
				 * Either scan location is now at a semicolon or at the end.
				 * If on semicolon we must consume it. */
				let c = contentScanner.scanCharacter()
				assert(c == Modifier.separatorChar)
			}
			guard contentScanner.isAtEnd else {
				/* Not all modifiers parsed in the content. */
				throw DummyError()
			}
		} catch {
			scanner.currentIndex = originalScannerIndex
			return nil
		}
	}
	
	public var description: String {
		return "ESC\(rawValue.dropFirst())"
	}
	
	private static let escapeChar = Character("\u{1B}")
	private static let csiChar    = Character("[") /* An SGR is a CSI. */
	private static let sgrEndChar = Character("m")
	
	private static let possibleParameterBytes    = CharacterSet(charactersIn: Unicode.Scalar(0x30)...Unicode.Scalar(0x3F))
	private static let possibleIntermediateBytes = CharacterSet(charactersIn: Unicode.Scalar(0x20)...Unicode.Scalar(0x2F))
	private static let possibleFinalByte         = CharacterSet(charactersIn: Unicode.Scalar(0x40)...Unicode.Scalar(0x7E))
	
}


extension Scanner {
	
	convenience init(forParsing string: String) {
		self.init(string: string)
		
		locale = nil
		caseSensitive = true
		charactersToBeSkipped = CharacterSet()
	}
	
}
