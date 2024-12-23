import Foundation


#if swift(>=5.5)
public protocol CLTLogger_Sendable : Sendable {}
#else
public protocol CLTLogger_Sendable {}
#endif
