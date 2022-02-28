import Foundation

extension Optional {
    
    func unwrapOrThrow(_ error: Error) throws -> Wrapped {
        guard let result = self else {
            throw error
        }
        return result
    }
}
