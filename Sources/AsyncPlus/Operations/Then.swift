import Foundation

// Note: For @discardableResult we require return type to be () or void. Otherwise, the operation produces a result which implies the result should be used in some kind of chained call.

// NOTE: We are unable to include variants of Then of the flavor T -> U. What would be the return type of self.then(...) when you are in the context of extending the Thenable protocol? An associated type is needed here, but that type applies only to the function call. Swift cannot handle this situation I think.

public protocol Thenable: Chainable {

//    associatedtype SelfFailable: Failable, Chainable where SelfFailable.T == T
//    associatedtype SelfAsync: Async, Chainable where SelfAsync.T == T
    
    
    //func thenEscaping<U, Result: Thenable>(_ body: @escaping (T) -> U) -> Result where Result.T == U

//    @discardableResult
//    func thenEscaping(_ body: @escaping (T) -> ()) -> SelfNode

    //func thenEscaping<U, Result: Thenable>(_ body: @escaping (T) throws -> ()) -> Result
    
//    func thenEscaping(_ body: @escaping (T) throws -> ()) -> SelfFailable

//    @discardableResult
//    func then(_ body: @escaping (T) async -> ()) -> SelfAsync

    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U>

    func then(_ body: @escaping (T) async throws -> ()) -> Promise<T>
}

extension Value: Thenable {

    // pattern:then
    // discard?
    public func then<U>(_ body: (T) -> U) -> Value<U> {
        // body?
        return Value<U>(body(value))
    }
    // endpattern
    
    // generate:then(discard? => @discardableResult, body(value) => value, body? => body(value), -> U => -> (), then<U> => then, U => T)

    // pattern:thenThrows
    public func then<U>(_ body: (T) throws -> U) -> Result<U> {
        do {
            // body?
            return Result(.success(try body(value)))
        } catch {
            return Result(.failure(error))
        }
    }
    // endpattern
    
    // generate:thenThrows(try body(value) => value, body? => try body(value), -> U => -> (), then<U> => then, U => T)

    // pattern:thenAsync
    // discard?
    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        // body?
        return Guarantee<U>(Task.init {
            return await body(value)
        })
    }
    // endPattern

    // generate:thenAsync()
    
//    @discardableResult
//    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
//        return Guarantee<T>(Task.init {
//            await body(value)
//            return value
//        })
//    }

    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try await body(value)
        })
    }

    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            try await body(value)
            return value
        })
    }

    // GENERATED
    @discardableResult
    public func then(_ body: (T) -> ()) -> Value<T> {
        body(value)
        return Value<T>(value)
    }
    
    public func then(_ body: (T) throws -> ()) -> Result<T> {
        do {
            try body(value)
            return Result(.success(value))
        } catch {
            return Result(.failure(error))
        }
    }
    
    // END GENERATED
}

extension Result: Thenable {

    
    public func then<U>(_ body: (T) -> U) -> Result<U> {
        switch result {
        case .success(let value):
            return Result<U>(.success(body(value)))
        case .failure(let error):
            return Result<U>(.failure(error))
        }
    }

    public func then(_ body: (T) -> ()) -> Result<T> {
        switch result {
        case .success(let value):
            body(value)
            return Result(.success(value))
        case .failure(let error):
            return Result(.failure(error))
        }
    }

    public func then<U>(_ body: (T) throws -> U) -> Result<U> {
        switch result {
        case .success(let value):
            do {
                return Result<U>(.success(try body(value)))
            } catch {
                return Result<U>(.failure(error))
            }
        case .failure(let error):
            return Result<U>(.failure(error))
        }
    }

    public func then(_ body: (T) throws -> ()) -> Result<T> {
        switch result {
        case .success(let value):
            do {
                try body(value)
                return Result(.success(value))
            } catch {
                return Result(.failure(error))
            }
        case .failure(let error):
            return Result(.failure(error))
        }
    }

    public func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            switch result {
            case .success(let value):
                return await body(value)
            case .failure(let error):
                throw error
            }
        })
    }

    public func then(_ body: @escaping (T) async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            switch result {
            case .success(let value):
                await body(value)
                return value
            case .failure(let error):
                throw error
            }
        })
    }

    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            switch result {
            case .success(let value):
                return try await body(value)
            case .failure(let error):
                throw error
            }
        })
    }

    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            switch result {
            case .success(let value):
                try await body(value)
                return value
            case .failure(let error):
                throw error
            }
        })
    }
}

extension Guarantee: Thenable {

    public func then<U>(_ body: @escaping (T) -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            return body(await task.value)
        })
    }

    @discardableResult
    public func then(_ body: @escaping (T) -> ()) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            let value = await task.value
            body(value)
            return value
        })
    }

    public func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try body(await task.value)
        })
    }

    public func then(_ body: @escaping (T) throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = await task.value
            try body(value)
            return value
        })
    }

    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            return await body(await task.value)
        })
    }

    @discardableResult
    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            let value = await task.value
            await body(value)
            return value
        })
    }

    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try await body(await task.value)
        })
    }

    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = await task.value
            try await body(value)
            return value
        })
    }
}

extension Promise: Thenable {

    public func then<U>(_ body: @escaping (T) -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return body(try await task.value)
        })
    }

    public func then(_ body: @escaping (T) -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value
            body(value)
            return value
        })
    }

    public func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try body(try await task.value)
        })
    }

    public func then(_ body: @escaping (T) throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value
            try body(value)
            return value
        })
    }

    public func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return await body(try await task.value)
        })
    }

    public func then(_ body: @escaping (T) async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value
            await body(value)
            return value
        })
    }

    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try await body(try await task.value)
        })
    }

    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value
            try await body(value)
            return value
        })
    }
}
