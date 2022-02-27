import Foundation

/// An internal enum for representing results; constrained further for compile-time optimization
enum Result<Success> {
    
    case success(Success)
    case failure(Error)
    
    /// Converts to a result of Any type
    func asAny() -> Result<Any> {
        switch self {
        case .success(let value):
            return .success(value as Any)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Force casts to a result of the specified type
    func forceSpecializeAs<T>(type: T.Type) -> Result<T> {
        switch self {
        case .success(let value):
            return .success(value as! T)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func asSwiftResult() -> Swift.Result<Success, Error> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
