import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body (I think).

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SResult<T>) async throws -> T {
    
    await body()
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        throw error
    }
}

extension NodeFailableInstant where Stage == ResultsStage {
    
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

extension NodeFailableInstant where Stage == FailuresStage {
    
    func ensure(_ body: () -> ()) -> CatchableResult<T> {
        body()
        return CatchableResult<T>(result)
    }
    
    func ensure(_ body: @escaping () async -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension NodeFailableAsync where Stage == ResultsStage {
    
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

extension NodeFailableAsync where Stage == FailuresStage {
    
    func ensure(_ body: @escaping () -> ()) -> CatchablePromise<T> {
        return CatchablePromise<T>(Task.init {
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
    
    func ensure(_ body: @escaping () async -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}


