import Foundation


extension NodeNonFailableInstant where Stage == ResultsStage {
    
    func then<U>(_ body: (T) -> U) -> ChainableValue<U> {
        return ChainableValue(body(value))
    }
    
    func then<U>(_ body: (T) throws -> U) -> ChainableResult<U> {
        do {
            return ChainableResult(.success(try body(value)))
        } catch {
            return ChainableResult(.failure(error))
        }
    }
    
    func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            return await body(value)
        })
    }
    
    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try await body(value)
        })
    }
}

extension NodeFailableInstant where Stage == ResultsStage {
    
    func then<U>(_ body: (T) -> U) -> ChainableResult<U> {
        switch result {
        case .success(let value):
            return ChainableResult(.success(body(value)))
        case .failure(let error):
            return ChainableResult(.failure(error))
        }
    }

    func then<U>(_ body: (T) throws -> U) -> ChainableResult<U> {
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
    
    func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            switch result {
            case .success(let value):
                return await body(value)
            case .failure(let error):
                throw error
            }
        })
    }
    
    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            switch result {
            case .success(let value):
                return try await body(value)
            case .failure(let error):
                throw error
            }
        })
    }
}

extension NodeNonFailableAsync where Stage == ResultsStage {
    
    func then<U>(_ body: @escaping (T) -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            return body(await task.value)
        })
    }
    
    func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try body(await task.value)
        })
    }
    
    func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            return await body(await task.value)
        })
    }
    
    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try await body(await task.value)
        })
    }
}

extension NodeFailableAsync where Stage == ResultsStage {
    
    func then<U>(_ body: @escaping (T) -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return body(try await task.value)
        })
    }
    
    func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try body(try await task.value)
        })
    }
    
    func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return await body(try await task.value)
        })
    }
    
    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            return try await body(try await task.value)
        })
    }
}
