import Foundation

// Note: When you are using recover and T is void or (), then either 1) You are intending to stack on further operations after the correction, or 2) you could have used `catch`. For this reason, there are no @discardableResult recover functions. For this use case, catch should be used.

public protocol Recoverable: Failable, Thenable {

    associatedtype SelfNonFailable: NonFailable, Thenable where SelfNonFailable.T == T

    func recoverEscaping(_ body: @escaping (Error) -> T) -> SelfNonFailable

    func recoverEscaping(_ body: @escaping (Error) throws -> T) -> Self

    func recover(_ body: @escaping (Error) async -> T) -> Guarantee<T>

    func recover(_ body: @escaping (Error) async throws -> T) -> Promise<T>
}

extension Result: Recoverable {

    // pattern:recover
    public func recover(_ body: (Error) -> T) -> Value<T> {
        switch result {
        case .success(let value):
            return Value(value)
        case .failure(let error):
            return Value(body(error))
        }
    }
    // endpattern
    
    // generate:recover(func recover => func recoverEscaping, body: => body: @escaping)

    // pattern:recoverThrows
    public func recover(_ body: (Error) throws -> T) -> Self {
        switch result {
        case .success(let value):
            return Self(.success(value))
        case .failure(let errorOriginal):
            do {
                return Self(.success(try body(errorOriginal)))
            } catch {
                return Self(.failure(error))
            }
        }
    }
    // endpattern
    
    // generate:recoverThrows(func recover => func recoverEscaping, body: => body: @escaping)

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

    // GENERATED
    // Generated from recover
    public func recoverEscaping(_ body: @escaping (Error) -> T) -> Value<T> {
        switch result {
        case .success(let value):
            return Value(value)
        case .failure(let error):
            return Value(body(error))
        }
    }
    
    // Generated from recoverThrows
    public func recoverEscaping(_ body: @escaping (Error) throws -> T) -> Self {
        switch result {
        case .success(let value):
            return Self(.success(value))
        case .failure(let errorOriginal):
            do {
                return Self(.success(try body(errorOriginal)))
            } catch {
                return Self(.failure(error))
            }
        }
    }
    // END GENERATED
}

extension Promise: Recoverable {

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
    
    public func recoverEscaping(_ body: @escaping (Error) -> T) -> Guarantee<T> {
        return recover(body)
    }

    public func recover(_ body: @escaping (Error) throws -> T) -> Self {
        return Self(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let errorOriginal):
                return try body(errorOriginal)
            }
        })
    }
    
    public func recoverEscaping(_ body: @escaping (Error) throws -> T) -> Self {
        return recover(body)
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
