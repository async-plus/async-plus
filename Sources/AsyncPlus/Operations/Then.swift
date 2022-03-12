import Foundation

// Note: For @discardableResult we require return type to be () or void. Otherwise, the operation produces a result which implies the result should be used in some kind of chained call.

//public protocol Thenable: Chainable {}

// NOTE: We are unable to include variants of Then of the flavor T -> U. What would be the return type of self.then(...) when you are in the context of extending the Thenable protocol? An associated type is needed here, but that type applies only to the function call. Swift cannot handle this situation I think.

public protocol Thenable: Chainable {

//    associatedtype SelfNode: Chainable where SelfNode.T == T
//    associatedtype SelfFailable: Failable, Chainable where SelfFailable.T == T
//    associatedtype SelfAsync: Async, Chainable where SelfAsync.T == T
//    
//    
//    //func thenEscaping<U, Result: Thenable>(_ body: @escaping (T) -> U) -> Result where Result.T == U
//
//    @discardableResult
//    func thenEscaping(_ body: @escaping (T) -> ()) -> SelfNode
//
//    //func thenEscaping<U, Result: Thenable>(_ body: @escaping (T) throws -> ()) -> Result
//    
//    func thenEscaping(_ body: @escaping (T) throws -> ()) -> SelfFailable
//
//    @discardableResult
//    func then(_ body: @escaping (T) async -> ()) -> SelfAsync
//
//    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U>
//
//    func then(_ body: @escaping (T) async throws -> ()) -> Promise<T>
}

//extension Value: Thenable2 {

//    public func then<U>(_ body: (T) -> U) -> Value<U> {
//        return Value<U>(body(value))
//    }
//
//    public func thenEscaping<U>(_ body: @escaping (T) -> U) -> Value<U> {
//        return Value<U>(body(value))
//    }
//
//    @discardableResult
//    public func then(_ body: (T) -> ()) -> Value<T> {
//        body(value)
//        return Value<T>(value)
//    }
//
//    @discardableResult
//    public func thenEscaping(_ body: @escaping (T) -> ()) -> Value<T> {
//        body(value)
//        return Value<T>(value)
//    }
//
//    public func then<U>(_ body: (T) throws -> U) -> Result<U> {
//        do {
//            return Result(.success(try body(value)))
//        } catch {
//            return Result(.failure(error))
//        }
//    }
//
//    public func thenEscaping<U>(_ body: @escaping (T) throws -> U) -> Result<U> {
//        do {
//            return Result(.success(try body(value)))
//        } catch {
//            return Result(.failure(error))
//        }
//    }
//
//    public func then(_ body: (T) throws -> ()) -> Result<T> {
//        do {
//            try body(value)
//            return Result(.success(value))
//        } catch {
//            return Result(.failure(error))
//        }
//    }
//
//    public func thenEscaping(_ body: @escaping (T) throws -> ()) -> Result<T> {
//        do {
//            try body(value)
//            return Result(.success(value))
//        } catch {
//            return Result(.failure(error))
//        }
//    }
//
//    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
//        return Guarantee<U>(Task.init {
//            return await body(value)
//        })
//    }
//
//    @discardableResult
//    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
//        return Guarantee<T>(Task.init {
//            await body(value)
//            return value
//        })
//    }
//
//    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return try await body(value)
//        })
//    }
//
//    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            try await body(value)
//            return value
//        })
//    }
//}

//extension Result: Thenable2 {
//
//    public func then<U>(_ body: (T) -> U) -> Result<U> {
//        switch result {
//        case .success(let value):
//            return Result(.success(body(value)))
//        case .failure(let error):
//            return Result(.failure(error))
//        }
//    }
//
//    public func then(_ body: (T) -> ()) -> Result<T> {
//        switch result {
//        case .success(let value):
//            body(value)
//            return Result(.success(value))
//        case .failure(let error):
//            return Result(.failure(error))
//        }
//    }
//
//    public func then<U>(_ body: (T) throws -> U) -> Result<U> {
//        switch result {
//        case .success(let value):
//            do {
//                return Result(.success(try body(value)))
//            } catch {
//                return Result(.failure(error))
//            }
//        case .failure(let error):
//            return Result(.failure(error))
//        }
//    }
//
//    public func then(_ body: (T) throws -> ()) -> Result<T> {
//        switch result {
//        case .success(let value):
//            do {
//                try body(value)
//                return Result(.success(value))
//            } catch {
//                return Result(.failure(error))
//            }
//        case .failure(let error):
//            return Result(.failure(error))
//        }
//    }
//
//    public func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            switch result {
//            case .success(let value):
//                return await body(value)
//            case .failure(let error):
//                throw error
//            }
//        })
//    }
//
//    public func then(_ body: @escaping (T) async -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            switch result {
//            case .success(let value):
//                await body(value)
//                return value
//            case .failure(let error):
//                throw error
//            }
//        })
//    }
//
//    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            switch result {
//            case .success(let value):
//                return try await body(value)
//            case .failure(let error):
//                throw error
//            }
//        })
//    }
//
//    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            switch result {
//            case .success(let value):
//                try await body(value)
//                return value
//            case .failure(let error):
//                throw error
//            }
//        })
//    }
//}
//
//extension Guarantee: Thenable2 {
//
//    public func then<U>(_ body: @escaping (T) -> U) -> Guarantee<U> {
//        return Guarantee<U>(Task.init {
//            return body(await task.value)
//        })
//    }
//
//    @discardableResult
//    public func then(_ body: @escaping (T) -> ()) -> Guarantee<T> {
//        return Guarantee<T>(Task.init {
//            let value = await task.value
//            body(value)
//            return value
//        })
//    }
//
//    public func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return try body(await task.value)
//        })
//    }
//
//    public func then(_ body: @escaping (T) throws -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            let value = await task.value
//            try body(value)
//            return value
//        })
//    }
//
//    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
//        return Guarantee<U>(Task.init {
//            return await body(await task.value)
//        })
//    }
//
//    @discardableResult
//    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
//        return Guarantee<T>(Task.init {
//            let value = await task.value
//            await body(value)
//            return value
//        })
//    }
//
//    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return try await body(await task.value)
//        })
//    }
//
//    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            let value = await task.value
//            try await body(value)
//            return value
//        })
//    }
//}

extension Promise {

    // cg:pattern:"then"
    public func then<U>(_ body: @escaping (T) -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return body(try await task.value)
        })
    }
    // cg:endpattern
    
    // cg:generate:then(then -> thenEscaping)
    
    // cg:start
    // cg:end
    
    public func thenEscaping<U, Result>(_ body: @escaping (T) -> U) -> Result where U == Result.T, Result : Chainable {
        return Promise<U>(Task.init {
            return body(try await task.value)
        }) as! Result
    }

    public func then(_ body: @escaping (T) -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value
            body(value)
            return value
        })
    }
    
    @discardableResult
    public func thenEscaping(_ body: @escaping (T) -> ()) -> Promise<T> {
        return then(body)
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
    
    public func thenEscaping(_ body: @escaping (T) throws -> ()) -> Promise<T> {
        return then(body)
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
