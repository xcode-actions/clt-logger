// swift-tools-version:5.3
import PackageDescription


let package = Package(
	name: "CLTLogger",
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2")
	],
	targets: [
		.target(name: "CLTLogger", dependencies: [
			.product(name: "Logging", package: "swift-log")
		]),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"])
	]
)
