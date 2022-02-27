import Foundation

/// An internal enum for representing results; constrained further for compile-time optimization
enum Result<T> {
    
    case success(T)
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
    func forceSpecializeAs<U>(type: U.Type) -> Result<U> {
        switch self {
        case .success(let value):
            return .success(value as! U)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func asSwiftResult() -> Swift.Result<T, Error> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
