import Foundation

import Logging



/* The @Sendable attribute is only available starting at Swift 5.5.
 * We make these methods only available starting at Swift 5.8 for our convenience (avoids creating another Package@swift-... file)
 *  and because for Swift <5.8 the non-@Sendable variants of the methods are available. */
extension CLTLogger {
	
	@Sendable
	public init(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) {
		self.init(metadataProvider: metadataProvider)
	}
	
	@Sendable
	public static func initWithLabelMetadata(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) -> CLTLogger {
		var res = self.init(metadataProvider: metadataProvider)
		res.metadata = ["zz-label": "\(label)"]
		return res
	}
	
	@Sendable
	public static func initWithDateMetadata(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) -> CLTLogger {
		return self.init(metadataProvider: .init{ ["zz-date": "\(Date())"].merging(metadataProvider?.get() ?? [:], uniquingKeysWith: { _, new in new }) })
	}
	
	@Sendable
	public static func initWithLabelAndDateMetadata(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) -> CLTLogger {
		var res = self.init(metadataProvider: .init{ ["zz-date": "\(Date())"].merging(metadataProvider?.get() ?? [:], uniquingKeysWith: { _, new in new }) })
		res.metadata = ["zz-label": "\(label)"]
		return res
	}
	
}
