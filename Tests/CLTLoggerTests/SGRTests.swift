import Foundation
import XCTest

@testable import CLTLogger



/* TODO: A lot more tests! */
final class SGRTests : XCTestCase {
	
	func testSGRParseFail() {
		XCTAssertNil(SGR(rawValue: "\(escape)[38;2;255;255m"))
		XCTAssertNil(SGR(rawValue: "\(escape)[38;2;255;255;+1m"))
	}
	
	func testSGRParse() {
		XCTAssertEqual(SGR(rawValue: "\(escape)[m"), SGR(.reset))
		XCTAssertEqual(SGR(rawValue: "\(escape)[0m"), SGR(.reset))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38;5;7m"), SGR(.fgColorTo256PaletteValue(7)))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38;2;255;255;0m"), SGR(.fgColorToRGB(red: 0xFF, green: 0xFF, blue: 0x00)))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38:4::255:255:0:0::m"), SGR(.fgColorToCMYKUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, black: 0x00, colorSpaceInfo: nil)))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38:4:2:255:255:0:0::1m"), SGR(.fgColorToCMYKUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, black: 0x00, colorSpaceInfo: .init(colorSpaceId: 2, colorSpaceTolerance: nil, colorSpaceAssociatedWithTolerance: .cielab))))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38:4:2:255:255:0:0:7:1m"), SGR(.fgColorToCMYKUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, black: 0x00, colorSpaceInfo: .init(colorSpaceId: 2, colorSpaceTolerance: 7, colorSpaceAssociatedWithTolerance: .cielab))))
		/* This one I’m not so sure, but Wikipedia says empty values should be read as 0, so here we go. */
		XCTAssertEqual(SGR(rawValue: "\(escape)[38;2;255;255;m"), SGR(.fgColorToRGB(red: 0xFF, green: 0xFF, blue: 0x00)))
	}
	
	func testMultipleSGRParse() {
		XCTAssertEqual(SGR(rawValue: "\(escape)[38;5;7;m"), SGR(.fgColorTo256PaletteValue(7), .reset))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38;2;255;255;0;m"), SGR(.fgColorToRGB(red: 0xFF, green: 0xFF, blue: 0x00), .reset))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38:4::255:255:0:0::;;1m"), SGR(.fgColorToCMYKUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, black: 0x00, colorSpaceInfo: nil), .reset, .bold))
		XCTAssertEqual(SGR(rawValue: "\(escape)[38:4::255:255:0:0::;;1m"), SGR(.fgColorToCMYKUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, black: 0x00, colorSpaceInfo: nil), .reset, .bold))
	}
	
	func testVisual1() {
		XCTAssertTrue(true, "We only want to see how the output look, so please see the logs.")
		
		/* Supported in Terminal and in iTerm2. */
		visualPrint(SGR(.fgColorTo4BitMagenta).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorTo256PaletteValue(27)).rawValue + "Hello" + SGR.reset.rawValue)
		
		/* Supported in iTerm2, not in Terminal. */
		visualPrint(SGR(.fgColorTo256PaletteValueODAFormat(27)).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorToRGB(red: 0xFF, green: 0x00, blue: 0x00)).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorToRGBUsingODAFormat(red: 0xFF, green: 0x00, blue: 0x00, colorSpaceInfo: nil)).rawValue + "Hello" + SGR.reset.rawValue)
		
		/* Not supported in iTerm2, nor in Terminal. */
		visualPrint(SGR(.fgColorToTransparent).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorTo4BitRed, .fgColorToImplementationDefined).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorToRGBUsingODAFormat(red: 0xFF, green: 0x00, blue: nil, colorSpaceInfo: nil)).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorToCMYUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, colorSpaceInfo: nil)).rawValue + "Hello" + SGR.reset.rawValue)
		visualPrint(SGR(.fgColorToCMYKUsingODAFormat(cyan: 0xFF, magenta: 0xFF, yellow: 0x00, black: 0x00, colorSpaceInfo: nil)).rawValue + "Hello" + SGR.reset.rawValue)
	}
	
	private let escape = "\u{1B}"
	
	private func visualPrint(_ str: String) {
		print(str + " <- " + str.replacingOccurrences(of: escape, with: "ESC"))
	}
	
}
