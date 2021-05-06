import XCTest
@testable import CLTLogger



final class SGRTests: XCTestCase {
	
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
	
	private func visualPrint(_ str: String) {
		print(str + " <- ", terminator: "")
		print(str.replacingOccurrences(of: "\u{1B}", with: "ESC"))
	}
	
}
