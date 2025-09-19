// swift-tools-version:5.1
import PackageDescription


let package = Package(
	name: "clt-logger",
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.5.1"),
	],
	targets: [
		.target(name: "CLTLogger", dependencies: [
			.product(name: "Logging", package: "swift-log"),
		], path: "Sources", exclude: ["CLTLogger+WithSendable.swift"]),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"])
	]
)
