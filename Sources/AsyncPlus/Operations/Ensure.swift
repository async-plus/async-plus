import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body, as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of ending the chain.

// Must work for partially caught result, caught result, and thenable
extension ChainableResult {
    
    public func ensure(_ body: () -> ()) -> Self {
        body()
        return Self(result)
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> Self {
        return Self(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension AnyResult where Self: Caught {
    
    // TODO: Bug: 
    public func ensure(_ body: () -> ()) -> CaughtResult<T> {
        body()
        return CaughtResult<T>(result)
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension AnyPromise where Self: Thenable {
    
    public func ensure(_ body: @escaping () -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

extension AnyPromise where Self: Caught {
    
    public func ensure(_ body: @escaping () -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SimpleResult<T>) async throws -> T {
    
    await body()
    return try result.get()
}
