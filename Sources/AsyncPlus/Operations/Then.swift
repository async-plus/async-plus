import Foundation

// Note: For @discardableResult we require return type to be () or void. Otherwise, the operation produces a result which implies the result should be used in some kind of chained call.

extension NodeNonFailableInstant where Stage == Thenable {
    
    public func then<U>(_ body: (T) -> U) -> ChainableValue<U> {
        return ChainableValue(body(value))
    }
    
    @discardableResult
    public func then(_ body: (T) -> ()) -> ChainableValue<T> {
        body(value)
        return ChainableValue(value)
    }
    
    public func then<U>(_ body: (T) throws -> U) -> ChainableResult<U> {
        do {
            return ChainableResult(.success(try body(value)))
        } catch {
            return ChainableResult(.failure(error))
        }
    }
    
    public func then(_ body: (T) throws -> ()) -> ChainableResult<T> {
        do {
            try body(value)
            return ChainableResult(.success(value))
        } catch {
            return ChainableResult(.failure(error))
        }
    }
    
    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            return await body(value)
        })
    }
    
    @discardableResult
    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            await body(value)
            return value
        })
    }
    
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
}

extension NodeFailableInstant where Stage == Thenable {
    
    public func then<U>(_ body: (T) -> U) -> ChainableResult<U> {
        switch result {
        case .success(let value):
            return ChainableResult(.success(body(value)))
        case .failure(let error):
            return ChainableResult(.failure(error))
        }
    }
    
    public func then(_ body: (T) -> ()) -> ChainableResult<T> {
        switch result {
        case .success(let value):
            body(value)
            return ChainableResult(.success(value))
        case .failure(let error):
            return ChainableResult(.failure(error))
        }
    }

    public func then<U>(_ body: (T) throws -> U) -> ChainableResult<U> {
        switch result {
        case .success(let value):
            do {
                return ChainableResult(.success(try body(value)))
            } catch {
                return ChainableResult(.failure(error))
            }
        case .failure(let error):
            return ChainableResult(.failure(error))
        }
    }
    
    public func then(_ body: (T) throws -> ()) -> ChainableResult<T> {
        switch result {
        case .success(let value):
            do {
                try body(value)
                return ChainableResult(.success(value))
            } catch {
                return ChainableResult(.failure(error))
            }
        case .failure(let error):
            return ChainableResult(.failure(error))
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

extension NodeNonFailableAsync where Stage == Thenable {
    
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

extension NodeFailableAsync where Stage == Thenable {
    
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
