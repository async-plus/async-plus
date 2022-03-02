import Foundation


// Note: Catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to progagate the error, or chained with another `catch` operation with a non-throwing body.

private func catchAsyncBody<T>(_ body: @escaping (Error) async -> (), result: SimpleResult<T>) async throws -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        await body(error)
        throw error
    }
}

private func catchAsyncThrowsBody<T>(_ body: @escaping (Error) async throws -> (), result: SimpleResult<T>) async throws -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        try await body(error)
        throw error
    }
}

extension ChainableResult {

    @discardableResult
    public func `catch`(_ body: (Error) -> ()) -> CaughtResult<T> {
        if case .failure(let error) = result {
            body(error)
        }
        return CaughtResult(result)
    }

    public func `catch`(_ body: (Error) throws -> ()) -> PartiallyCaughtResult<T> {
        do {
            if case .failure(let error) = result {
                try body(error)
            }
            return(PartiallyCaughtResult(result))
        } catch {
            return PartiallyCaughtResult(.failure(error))
        }
    }
    
    @discardableResult
    public func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: result)
        })
    }

    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: result)
        })
    }
}

extension ChainablePromise {

    // These catch functions are async because the current result is already async.
    @discardableResult
    public func `catch`(_ body: @escaping (Error) -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let error):
                body(error)
                throw error
            }
        })
    }

    public func `catch`(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
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
    public func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: await task.result)
        })
    }

    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: await task.result)
        })
    }
}
