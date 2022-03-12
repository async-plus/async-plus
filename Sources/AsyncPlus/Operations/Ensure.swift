import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body, as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of ending the chain.

public protocol Ensurable: Failable, Chainable {
    
    associatedtype SelfNode: Ensurable where SelfNode.T == T
    associatedtype SelfAsync: Async, Ensurable where SelfAsync.T == T
    
    func ensureEscaping(_ body: @escaping () -> ()) -> SelfNode

    func ensure(_ body: @escaping () async -> ()) -> SelfAsync
}

extension Result: Ensurable {

    public typealias SelfNode = Result<T>
    public typealias SelfAsync = Promise<T>
    
    public func ensure(_ body: () -> ()) -> Result<T> {
        body()
        return Result<T>(result)
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> Result<T> {
        return ensure(body)
    }

    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

// TODO: Remove duplicate code by a protocol extension of Ensurable where Self: HasResult - then make HasResult require a constructor
extension PartiallyCaughtResult: Ensurable {

    public typealias SelfNode = PartiallyCaughtResult<T>
    public typealias SelfAsync = PartiallyCaughtPromise<T>
    
    public func ensure(_ body: () -> ()) -> PartiallyCaughtResult<T> {
        body()
        return PartiallyCaughtResult<T>(result)
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> PartiallyCaughtResult<T> {
        return ensure(body)
    }

    public func ensure(_ body: @escaping () async -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

// TODO: Codegen
extension CaughtResult: Ensurable {

    public typealias SelfNode = CaughtResult<T>
    public typealias SelfAsync = CaughtPromise<T>
    
    public func ensure(_ body: () -> ()) -> CaughtResult<T> {
        body()
        return CaughtResult<T>(result)
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> CaughtResult<T> {
        return ensure(body)
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension Promise: Ensurable {

    public typealias SelfNode = Promise<T>
    public typealias SelfAsync = Promise<T>
    
    public func ensure(_ body: @escaping () -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> Promise<T> {
        return ensure(body)
    }

    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

// TODO: Codegen
extension PartiallyCaughtPromise: Ensurable {

    public typealias SelfNode = PartiallyCaughtPromise<T>
    public typealias SelfAsync = PartiallyCaughtPromise<T>
    
    public func ensure(_ body: @escaping () -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> PartiallyCaughtPromise<T> {
        return ensure(body)
    }

    public func ensure(_ body: @escaping () async -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

// TODO: Codegen
extension CaughtPromise: Ensurable {

    public typealias SelfNode = CaughtPromise<T>
    public typealias SelfAsync = CaughtPromise<T>
    
    public func ensure(_ body: @escaping () -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> CaughtPromise<T> {
        return ensure(body)
    }

    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SimpleResult<T>) async throws -> T {

    await body()
    return try result.get()
}

