// swift-tools-version:5.3
import PackageDescription


/* Swift conditional compilation flags:
 *   - TERMINAL_EMOJI: Correct emoji alignment for Terminal.app */

let package = Package(
	name: "clt-logger",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
		.package(url: "https://github.com/apple/swift-system.git", from: "0.0.2")
	],
	targets: [
		.target(name: "CLTLogger", dependencies: [
			.product(name: "Logging",       package: "swift-log"),
			.product(name: "SystemPackage", package: "swift-system")
		]),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"])
	]
)
