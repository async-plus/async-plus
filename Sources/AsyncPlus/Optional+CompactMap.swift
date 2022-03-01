import Foundation

public struct CompactMapError: Error {
    public init() {}
}

extension Optional {
    
    public func unwrapOrThrow(_ error: Error = CompactMapError()) throws -> Wrapped {
        guard let result = self else {
            throw error
        }
        return result
    }
}
