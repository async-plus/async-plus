import Foundation

/// Simple result
typealias SResult<Success> = Result<Success, Error>

extension SResult {
    
    /// Converts to a result of Any type
    func asAny() -> SResult<Any> {
        switch self {
        case .success(let value):
            return .success(value as Any)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Force casts to a result of the specified type
    func forceSpecializeAs<U>(type: U.Type) -> SResult<U> {
        switch self {
        case .success(let value):
            return .success(value as! U)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func asSwiftResult() -> Result<Success, Error> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
