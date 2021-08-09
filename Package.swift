// swift-tools-version:5.1
import PackageDescription


/* Swift conditional compilation flags:
 *   - TERMINAL_EMOJI: Correct emoji alignment for Terminal.app */

let package = Package(
	name: "clt-logger",
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2")
	],
	targets: [
		.target(name: "CLTLogger", dependencies: [
			.product(name: "Logging",       package: "swift-log")
		]),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"])
	]
)
