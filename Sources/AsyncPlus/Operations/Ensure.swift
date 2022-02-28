import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body (I think), as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of endingg the chain.

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SResult<T>) async throws -> T {
    
    await body()
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        throw error
    }
}

extension NodeFailableInstant where Stage == Thenable {
    
    func ensure(_ body: () -> ()) -> ChainableResult<T> {
        body()
        return ChainableResult<T>(result)
    }
    
    func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension NodeFailableInstant where Stage: Caught {
    
    func ensure(_ body: () -> ()) -> CaughtResult<T> {
        body()
        return CaughtResult<T>(result)
    }
    
    func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension NodeFailableAsync where Stage == Thenable {
    
    func ensure(_ body: @escaping () -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let result = await task.result
            body()
            switch result {
            case .success(let value):
                return value
            case .failure(let error):
                throw error
            }
        })
    }
    
    func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

extension NodeFailableAsync where Stage: Caught {
    
    func ensure(_ body: @escaping () -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            let result = await task.result
            body()
            switch result {
            case .success(let value):
                return value
            case .failure(let error):
                throw error
            }
        })
    }
    
    func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}


