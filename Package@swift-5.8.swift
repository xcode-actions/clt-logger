// swift-tools-version:5.8
import PackageDescription


//let swiftSettings: [SwiftSetting] = []
let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("StrictConcurrency")]

let package = Package(
	name: "clt-logger",
	platforms: [
		.macOS(.v11),
		.tvOS(.v14),
		.iOS(.v14),
		.watchOS(.v7),
	],
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.5.1"),
	],
	targets: [
		.target(name: "CLTLogger", dependencies: [
			.product(name: "Logging", package: "swift-log"),
		], path: "Sources", exclude: ["CLTLogger+NoSendable.swift"], swiftSettings: swiftSettings),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"], swiftSettings: swiftSettings)
	]
)
