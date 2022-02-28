import Foundation


// Note: catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to progagate the error, or chained with another `catch` operation with a non-throwing body.

private func catchAsyncBody<T>(_ body: @escaping (Error) async -> (), result: SResult<T>) async throws -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        // TODO: What to do with previous error
        await body(error)
        throw error
    }
}

private func catchAsyncThrowsBody<T>(_ body: @escaping (Error) async throws -> (), result: SResult<T>) async throws -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        // TODO: What to do with previous error
        try await body(error)
        throw error
    }
}

extension NodeFailableInstant {

    @discardableResult
    func `catch`(_ body: (Error) -> ()) -> CatchableResult<T> {
        if case .failure(let error) = result {
            body(error)
        }
        return CatchableResult(result)
    }

    func `catch`(_ body: (Error) throws -> ()) -> CatchableResult<T> {
        do {
            if case .failure(let error) = result {
                try body(error)
            }
            return(CatchableResult(result))
        } catch {
            // TODO: Compound error?
            return CatchableResult(.failure(error))
        }
    }
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            try await catchAsyncBody(body, result: result)
        })
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            try await catchAsyncThrowsBody(body, result: result)
        })
    }
}

extension NodeFailableAsync {

    // These catch functions are async because the current result is already async.
    @discardableResult
    func `catch`(_ body: @escaping (Error) -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let error):
                body(error)
                throw error
            }
        })
    }

    func `catch`(_ body: @escaping (Error) throws -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let error):
                try body(error)
                throw error
            }
        })
    }
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            try await catchAsyncBody(body, result: await task.result)
        })
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> CatchablePromise<T> {
        return CatchablePromise(Task.init {
            try await catchAsyncThrowsBody(body, result: await task.result)
        })
    }
}



