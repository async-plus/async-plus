import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body, as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of ending the chain.

public protocol Ensurable: Failable, Chainable {
    
    associatedtype SelfAsync: HasFailableTask, Ensurable where SelfAsync.T == T
    
    func ensureEscaping(_ body: @escaping () -> ()) -> Self

    func ensure(_ body: @escaping () async -> ()) -> SelfAsync
}

extension Ensurable where Self: HasResult {
    // cg:pattern:ensure
    public func ensure(_ body: () -> ()) -> Self {
        body()
        return Self(result)
    }
    // cg:endpattern

    // cg:generate:ensure(func ensure => func ensureEscaping, body: => body: @escaping)
    
    public func ensure(_ body: @escaping () async -> ()) -> SelfAsync {
        return SelfAsync(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }

    // cg:start
    public func ensureEscaping(_ body: @escaping () -> ()) -> Self {
        body()
        return Self(result)
    }
    
    // cg:end
}

extension Result: Ensurable {

    public typealias SelfNode = Result<T>
    public typealias SelfAsync = Promise<T>
}

extension PartiallyCaughtResult: Ensurable {

    public typealias SelfNode = PartiallyCaughtResult<T>
    public typealias SelfAsync = PartiallyCaughtPromise<T>
}

extension CaughtResult: Ensurable {

    public typealias SelfNode = CaughtResult<T>
    public typealias SelfAsync = CaughtPromise<T>
}

extension Ensurable where Self: HasFailableTask {
    
    public func ensure(_ body: @escaping () -> ()) -> Self {
        return Self(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensureEscaping(_ body: @escaping () -> ()) -> Self {
        return ensure(body)
    }

    public func ensure(_ body: @escaping () async -> ()) -> SelfAsync {
        return SelfAsync(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

extension Promise: Ensurable {

    public typealias SelfNode = Promise<T>
    public typealias SelfAsync = Promise<T>
}

extension PartiallyCaughtPromise: Ensurable {

    public typealias SelfNode = PartiallyCaughtPromise<T>
    public typealias SelfAsync = PartiallyCaughtPromise<T>
}

// TODO: Codegen
extension CaughtPromise: Ensurable {

    public typealias SelfNode = CaughtPromise<T>
    public typealias SelfAsync = CaughtPromise<T>
}

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SimpleResult<T>) async throws -> T {

    await body()
    return try result.get()
}

