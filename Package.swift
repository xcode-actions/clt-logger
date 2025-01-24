// swift-tools-version:5.2
import PackageDescription


let package = Package(
	name: "clt-logger",
	/* Not sure how to test for platforms for Swift pre-5.8; let’s not do it. */
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
