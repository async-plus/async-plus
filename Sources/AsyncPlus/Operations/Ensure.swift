import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body, as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of ending the chain.

extension NodeFailableInstant where Stage == Thenable {
    
    public func ensure(_ body: () -> ()) -> ChainableResult<T> {
        body()
        return ChainableResult<T>(result)
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension NodeFailableInstant where Stage: Caught {
    
    public func ensure(_ body: () -> ()) -> GenericNodeFailableInstant<T, Stage> {
        body()
        return GenericNodeFailableInstant<T, Stage>(result)
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> GenericNodeFailableAsync<T, Stage> {
        return GenericNodeFailableAsync<T, Stage>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension NodeFailableAsync where Stage == Thenable {
    
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

extension NodeFailableAsync where Stage: Caught {
    
    public func ensure(_ body: @escaping () -> ()) -> GenericNodeFailableAsync<T, Stage> {
        return GenericNodeFailableAsync<T, Stage>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    public func ensure(_ body: @escaping () async -> ()) -> GenericNodeFailableAsync<T, Stage> {
        return GenericNodeFailableAsync<T, Stage>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SimpleResult<T>) async throws -> T {
    
    await body()
    return try result.get()
}
