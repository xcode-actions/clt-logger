import Foundation

import Logging



extension CLTLogger {
	
	public init(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) {
		self.init(metadataProvider: metadataProvider)
	}
	
	public static func initWithLabelMetadata(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) -> CLTLogger {
		var res = self.init(metadataProvider: metadataProvider)
		res.metadata = ["zz-label": "\(label)"]
		return res
	}
	
	public static func initWithDateMetadata(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) -> CLTLogger {
		return self.init(metadataProvider: .init{ ["zz-date": "\(Date())"].merging(metadataProvider?.get() ?? [:], uniquingKeysWith: { _, new in new }) })
	}
	
	public static func initWithLabelAndDateMetadata(label: String, metadataProvider: Logger.MetadataProvider? = LoggingSystem.metadataProvider) -> CLTLogger {
		var res = self.init(metadataProvider: .init{ ["zz-date": "\(Date())"].merging(metadataProvider?.get() ?? [:], uniquingKeysWith: { _, new in new }) })
		res.metadata = ["zz-label": "\(label)"]
		return res
	}
	
}
