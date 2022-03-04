//import Foundation
//
//// Note: For @discardableResult we require return type to be () or void. Otherwise, the operation produces a result which implies the result should be used in some kind of chained call.
//
//extension AnyStageValue where Stage == Thenable {
//    
//    public func then<U>(_ body: (T) -> U) -> Value<U> {
//        return Value(body(value))
//    }
//    
//    @discardableResult
//    public func then(_ body: (T) -> ()) -> Value<T> {
//        body(value)
//        return Value(value)
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
//    public func then(_ body: (T) throws -> ()) -> Result<T> {
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
//
//extension AnyStageResult where Stage == Thenable {
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
//extension Guarantee where Stage == Thenable {
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
//
//extension AnyStagePromise where Stage == Thenable {
//    
//    public func then<U>(_ body: @escaping (T) -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return body(try await task.value)
//        })
//    }
//    
//    public func then(_ body: @escaping (T) -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            let value = try await task.value
//            body(value)
//            return value
//        })
//    }
//    
//    public func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return try body(try await task.value)
//        })
//    }
//    
//    public func then(_ body: @escaping (T) throws -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            let value = try await task.value
//            try body(value)
//            return value
//        })
//    }
//    
//    public func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return await body(try await task.value)
//        })
//    }
//    
//    public func then(_ body: @escaping (T) async -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            let value = try await task.value
//            await body(value)
//            return value
//        })
//    }
//    
//    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
//        return Promise<U>(Task.init {
//            return try await body(try await task.value)
//        })
//    }
//    
//    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
//        return Promise<T>(Task.init {
//            let value = try await task.value
//            try await body(value)
//            return value
//        })
//    }
//}
