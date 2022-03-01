import Foundation

struct CompactMapError: Error {
}

extension Optional {
    
    func unwrapOrThrow(_ error: Error = CompactMapError()) throws -> Wrapped {
        guard let result = self else {
            throw error
        }
        return result
    }
}
