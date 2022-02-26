import Foundation

/// An internal enum for representing results; the built-in result type has a "Failure" generic type which is unused for our purposes.
enum Result<Success> {
    
    case success(Success)
    case failure(Error)
    
    /// Converts to a result of Any type
    func asAny() -> Result<Any> {
        switch self {
        case Result<Success>.success(let v):
            return Result<Any>.success(v as Any)
        case Result<Success>.failure(let error):
            return Result<Any>.failure(error)
        }
    }
    
    /// Force casts to a result of the specified type
    func forceSpecializeAs<T>(type: T.Type) -> Result<T> {
        switch self {
        case Result<Success>.success(let v):
            return Result<T>.success(v as! T)
        case Result<Success>.failure(let error):
            return Result<T>.failure(error)
        }
    }
}
