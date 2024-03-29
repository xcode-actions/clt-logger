// swift-tools-version:5.3
import PackageDescription


let package = Package(
	name: "clt-logger",
	platforms: [
		.macOS(.v11),
		.tvOS(.v14),
		.iOS(.v14),
		.watchOS(.v7)
	],
	products: [
		.library(name: "CLTLogger", targets: ["CLTLogger"])
	],
	dependencies: {
		var ret = [Package.Dependency]()
		ret.append(.package(url: "https://github.com/apple/swift-log.git", from: "1.5.1"))
#if !canImport(System)
		ret.append(.package(url: "https://github.com/apple/swift-system.git", from: "1.0.0"))
#endif
		return ret
	}(),
	targets: [
		.target(name: "CLTLogger", dependencies: {
			var ret = [Target.Dependency]()
			ret.append(.product(name: "Logging",       package: "swift-log"))
#if !canImport(System)
			ret.append(.product(name: "SystemPackage", package: "swift-system"))
#endif
			return ret
		}(), path: "Sources"),
		.testTarget(name: "CLTLoggerTests", dependencies: ["CLTLogger"], path: "Tests")
	]
)
