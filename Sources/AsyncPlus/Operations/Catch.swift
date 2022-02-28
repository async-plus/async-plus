import Foundation


// Note: catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to progagate the error, or chained with another `catch` operation with a non-throwing body.

extension NodeFailableInstant where Stage: Chainable {

    @discardableResult
    func `catch`(_ body: (Error) -> ()) -> CaughtResult<T> {
        if case .failure(let error) = result {
            body(error)
        }
        return CaughtResult(result)
    }

    func `catch`(_ body: (Error) throws -> ()) -> PartiallyCaughtResult<T> {
        do {
            if case .failure(let error) = result {
                // TODO: What to do with shadowed error
                try body(error)
            }
            return(PartiallyCaughtResult(result))
        } catch {
            return PartiallyCaughtResult(.failure(error))
        }
    }
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: result)
        })
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: result)
        })
    }
}

extension NodeFailableAsync where Stage: Chainable {

    // These catch functions are async because the current result is already async.
    @discardableResult
    func `catch`(_ body: @escaping (Error) -> ()) -> CaughtPromise<T> {
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

    func `catch`(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtPromise<T> {
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
    func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: await task.result)
        })
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: await task.result)
        })
    }
}

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
        // TODO: What to do with shadowed error
        try await body(error)
        throw error
    }
}

