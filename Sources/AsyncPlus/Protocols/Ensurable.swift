import Foundation

// Note: For now, ensurable is a separate protocol from Catchable because in the future we may want to allow non-failable chains to use `ensure`.

public protocol Ensurable: Failable, Chainable {
    
    associatedtype SelfNode: Ensurable
    associatedtype SelfAsync: Async, Ensurable
    
    func ensureEscaping(_ body: @escaping () -> ()) -> SelfNode

    func ensure(_ body: @escaping () async -> ()) -> SelfAsync
}


extension Result: Ensurable {

    public typealias SelfNode = Result<T>
    public typealias SelfAsync = Promise<T>
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> Result<T> {
        return ensure(body)
    }
}

extension PartiallyCaughtResult: Ensurable {

    public typealias SelfNode = PartiallyCaughtResult<T>
    public typealias SelfAsync = PartiallyCaughtPromise<T>
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> PartiallyCaughtResult<T> {
        return ensure(body)
    }
}

extension CaughtResult: Ensurable {

    public typealias SelfNode = CaughtResult<T>
    public typealias SelfAsync = CaughtPromise<T>
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> CaughtResult<T> {
        return ensure(body)
    }
}

extension Promise: Ensurable {

    public typealias SelfNode = Promise<T>
    public typealias SelfAsync = Promise<T>
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> Promise<T> {
        return ensure(body)
    }
}

extension PartiallyCaughtPromise: Ensurable {

    public typealias SelfNode = PartiallyCaughtPromise<T>
    public typealias SelfAsync = PartiallyCaughtPromise<T>
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> PartiallyCaughtPromise<T> {
        return ensure(body)
    }
}

extension CaughtPromise: Ensurable {

    public typealias SelfNode = CaughtPromise<T>
    public typealias SelfAsync = CaughtPromise<T>
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> CaughtPromise<T> {
        return ensure(body)
    }
}


