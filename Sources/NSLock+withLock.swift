#if (!canImport(Darwin) && swift(<6.0)) || swift(<5.7)
import Foundation



extension NSLock {
	
	func withLock<R>(_ body: () throws -> R) rethrows -> R {
		lock()
		defer {unlock()}
		return try body()
	}
	
}

#endif
