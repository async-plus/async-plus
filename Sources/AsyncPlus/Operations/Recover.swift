import Foundation

// Note: When you are using recover and T is void or (), then either 1) You are intending to stack on further operations after the correction, or 2) you could have used `catch`. For this reason, there are no @discardableResult recover functions. For this use case, catch should be used.

extension APResult {
    
    public func recover(_ body: (Error) -> T) -> Value<T> {
        switch result {
        case .success(let value):
            return Value(value)
        case .failure(let error):
            return Value(body(error))
        }
    }

    public func recover(_ body: (Error) throws -> T) -> APResult<T> {
        switch result {
        case .success(let value):
            return APResult(.success(value))
        case .failure(let errorOriginal):
            do {
                return APResult(.success(try body(errorOriginal)))
            } catch {
                return APResult(.failure(error))
            }
        }
    }
    
    public func recover(_ body: @escaping (Error) async -> T) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            await recoverAsyncBody(body, result: result)
        })
    }
    
    public func recover(_ body: @escaping (Error) async throws -> T) -> Promise<T> {
        return Promise<T>(Task.init {
            try await recoverAsyncThrowsBody(body, result: result)
        })
    }
}

extension Promise {
    
    // These recover functions are async because the current result is already async.
    public func recover(_ body: @escaping (Error) -> T) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let error):
                return body(error)
            }
        })
    }
    
    public func recover(_ body: @escaping (Error) throws -> T) -> Promise<T> {
        return Promise<T>(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let errorOriginal):
                return try body(errorOriginal)
            }
        })
    }
    
    public func recover(_ body: @escaping (Error) async -> T) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            await recoverAsyncBody(body, result: await task.result)
        })
    }
    
    public func recover(_ body: @escaping (Error) async throws -> T) -> Promise<T> {
        return Promise<T>(Task.init {
            try await recoverAsyncThrowsBody(body, result: await task.result)
        })
    }
}

private func recoverAsyncBody<T>(_ body: @escaping (Error) async -> T, result: SimpleResult<T>) async -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        return await body(error)
    }
}

private func recoverAsyncThrowsBody<T>(_ body: @escaping (Error) async throws -> T, result: SimpleResult<T>) async throws -> T {
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        return try await body(error)
    }
}
