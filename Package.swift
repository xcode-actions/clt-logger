// swift-tools-version:5.3
import PackageDescription


let package = Package(
	name: "clt-logger",
	platforms: [
		.macOS(.v10_12)
	],
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
		.package(url: "https://github.com/apple/swift-system.git", .revision("2ac0cdc24beff8af664c632f5ab352ec8ba8d068")) /* Sadly, standardOutput and standardError are not available in 0.0.1 */
	],
	targets: [
		.target(name: "CLTLogger", dependencies: [
			.product(name: "Logging",       package: "swift-log"),
			.product(name: "SystemPackage", package: "swift-system")
		]),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"])
	]
)
