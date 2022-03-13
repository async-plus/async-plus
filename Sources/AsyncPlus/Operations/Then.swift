import Foundation

// Note: For @discardableResult we require return type to be () or void. Otherwise, the operation produces a result which implies the result should be used in some kind of chained call.

// NOTE: We are unable to include variants of Then of the flavor T -> U. What would be the return type of self.then(...) when you are in the context of extending the Thenable protocol? An associated type is needed here, but that type applies only to the function call. Swift cannot handle this situation I think.

public protocol Thenable: Chainable {

//    associatedtype SelfFailable: Failable, Chainable where SelfFailable.T == T
//    associatedtype SelfAsync: Async, Chainable where SelfAsync.T == T
    
    
//    func thenEscaping<U, Result: Thenable>(_ body: @escaping (T) -> U) -> Result where Result.T == U

    // @discardableResult
    func thenEscaping(_ body: @escaping (T) -> ()) -> Self

    //func thenEscaping<U, Result: Thenable>(_ body: @escaping (T) throws -> ()) -> Result
    
//    func thenEscaping(_ body: @escaping (T) throws -> ()) -> SelfFailable

//    @discardableResult
//    func then(_ body: @escaping (T) async -> ()) -> SelfAsync

    func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U>

    func then(_ body: @escaping (T) async throws -> ()) -> Promise<T>
}

// ruleset:makeDiscardable(discard? => @discardableResult)
// ruleset:makeSameType(-> U => -> (), then<U> => then, U => T)
// ruleset:makeThenEscapingCopy(func then => func thenEscaping, makeEscaping)
// ruleset:makeThenEscapingCopyRenameOnly(func then => func thenEscaping)

extension Value: Thenable {

    // pattern:then
    // discard?
    public func then<U>(_ body: (T) -> U) -> Value<U> {
        // body?
        return Value<U>(body(value))
    }
    // endpattern
    
    // generate:then(makeThenEscapingCopy)
    // generate:then(body(value) => value, body? => body(value), makeSameType, makeDiscardable)
    // generate:then(..., makeThenEscapingCopy, Value<T> => Self)

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
    
    // generate:thenThrows(makeThenEscapingCopy)
    // generate:thenThrows(try body(value) => value, body? => try body(value), makeSameType)
    // generate:thenThrows(..., makeThenEscapingCopy)

    // pattern:thenAsync
    // discard?
    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            // body?
            return await body(value)
        })
    }
    // endpattern
    
    // generate:thenAsync(await body(value) => value, body? => await body(value), makeSameType, makeDiscardable)

    // pattern:thenAsyncThrows
    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return try await body(value)
        })
    }
    // endpattern

    // generate:thenAsyncThrows(try await body(value) => value, body? => try await body(value), makeSameType)

    // GENERATED
    // Generated from then
    // discard?
    public func thenEscaping<U>(_ body: @escaping (T) -> U) -> Value<U> {
        // body?
        return Value<U>(body(value))
    }
    
    // Generated from then
    @discardableResult
    public func then(_ body: (T) -> ()) -> Value<T> {
        body(value)
        return Value<T>(value)
    }
    
    // Generated from then
    @discardableResult
    public func thenEscaping(_ body: @escaping (T) -> ()) -> Self {
        body(value)
        return Self(value)
    }
    
    // Generated from thenThrows
    public func thenEscaping<U>(_ body: @escaping (T) throws -> U) -> Result<U> {
        do {
            // body?
            return Result(.success(try body(value)))
        } catch {
            return Result(.failure(error))
        }
    }
    
    // Generated from thenThrows
    public func then(_ body: (T) throws -> ()) -> Result<T> {
        do {
            try body(value)
            return Result(.success(value))
        } catch {
            return Result(.failure(error))
        }
    }
    
    // Generated from thenThrows
    public func thenEscaping(_ body: @escaping (T) throws -> ()) -> Result<T> {
        do {
            try body(value)
            return Result(.success(value))
        } catch {
            return Result(.failure(error))
        }
    }
    
    // Generated from thenAsync
    @discardableResult
    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            await body(value)
            return value
        })
    }
    
    // Generated from thenAsyncThrows
    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            try await body(value)
            return value
        })
    }
    // END GENERATED
}

extension Result: Thenable {

    // pattern:then
    public func then<U>(_ body: (T) -> U) -> Result<U> {
        switch result {
        case .success(let value):
            // body?
            return Result<U>(.success(body(value)))
        case .failure(let error):
            return Result<U>(.failure(error))
        }
    }
    // endpattern
    
    // generate:then(makeThenEscapingCopy)
    // generate:then(body(value) => value, body? => body(value), makeSameType)
    // generate:then(..., makeThenEscapingCopy, Result<T> => Self)

    // pattern:thenThrows
    public func then<U>(_ body: (T) throws -> U) -> Result<U> {
        switch result {
        case .success(let value):
            do {
                // body?
                return Result<U>(.success(try body(value)))
            } catch {
                return Result<U>(.failure(error))
            }
        case .failure(let error):
            return Result<U>(.failure(error))
        }
    }
    // endpattern
    
    // generate:thenThrows(makeThenEscapingCopy)
    // generate:thenThrows(try body(value) => value, body? => try body(value), makeSameType)
    // generate:thenThrows(..., makeThenEscapingCopy)

    // pattern:thenAsync
    public func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            switch result {
            case .success(let value):
                // body?
                return await body(value)
            case .failure(let error):
                throw error
            }
        })
    }
    // endpattern

    // generate:thenAsync(await body(value) => value, body? => await body(value), makeSameType)

    // pattern:thenAsyncThrows
    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            switch result {
            case .success(let value):
                // body?
                return try await body(value)
            case .failure(let error):
                throw error
            }
        })
    }
    // endpattern
    
    // generate:thenAsyncThrows(try await body(value) => value, body? => try await body(value), makeSameType)

    // GENERATED
    // Generated from then
    public func thenEscaping<U>(_ body: @escaping (T) -> U) -> Result<U> {
        switch result {
        case .success(let value):
            // body?
            return Result<U>(.success(body(value)))
        case .failure(let error):
            return Result<U>(.failure(error))
        }
    }
    
    // Generated from then
    public func then(_ body: (T) -> ()) -> Result<T> {
        switch result {
        case .success(let value):
            body(value)
            return Result<T>(.success(value))
        case .failure(let error):
            return Result<T>(.failure(error))
        }
    }
    
    // Generated from then
    public func thenEscaping(_ body: @escaping (T) -> ()) -> Self {
        switch result {
        case .success(let value):
            body(value)
            return Self(.success(value))
        case .failure(let error):
            return Self(.failure(error))
        }
    }
    
    // Generated from thenThrows
    public func thenEscaping<U>(_ body: @escaping (T) throws -> U) -> Result<U> {
        switch result {
        case .success(let value):
            do {
                // body?
                return Result<U>(.success(try body(value)))
            } catch {
                return Result<U>(.failure(error))
            }
        case .failure(let error):
            return Result<U>(.failure(error))
        }
    }
    
    // Generated from thenThrows
    public func then(_ body: (T) throws -> ()) -> Result<T> {
        switch result {
        case .success(let value):
            do {
                try body(value)
                return Result<T>(.success(value))
            } catch {
                return Result<T>(.failure(error))
            }
        case .failure(let error):
            return Result<T>(.failure(error))
        }
    }
    
    // Generated from thenThrows
    public func thenEscaping(_ body: @escaping (T) throws -> ()) -> Result<T> {
        switch result {
        case .success(let value):
            do {
                try body(value)
                return Result<T>(.success(value))
            } catch {
                return Result<T>(.failure(error))
            }
        case .failure(let error):
            return Result<T>(.failure(error))
        }
    }
    
    // Generated from thenAsync
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
    
    // Generated from thenAsyncThrows
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
    // END GENERATED
}

// This ruleset just throws away the body of the function and makes it pass through to then(body)

// ruleset:makeThenEscapingAlias(func then => func thenEscaping, \{(?:.|\n)+\} R=> { return then(body) })

extension Guarantee: Thenable {

    // pattern:then
    // discard?
    public func then<U>(_ body: @escaping (T) -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            // body?
            return body(await task.value)
        })
    }
    // endpattern
    
    // generate:then(makeThenEscapingAlias)
    // generate:then(body(await task.value) => value, body? => let value = await task.value; body(value), makeSameType, makeDiscardable)
    // generate:then(..., makeThenEscapingCopyRenameOnly, Guarantee<T> => Self)

    // pattern:thenThrows
    public func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return try body(await task.value)
        })
    }
    // endpattern
    
    // generate:thenThrows(makeThenEscapingAlias)
    // generate:thenThrows(try body(await task.value) => value, body? => let value = await task.value; try body(value), makeSameType)
    // generate:thenThrows(..., makeThenEscapingAlias)

    // pattern:thenAsync
    // discard?
    public func then<U>(_ body: @escaping (T) async -> U) -> Guarantee<U> {
        return Guarantee<U>(Task.init {
            // body?
            return await body(await task.value)
        })
    }
    // endpattern
    
    // generate:thenAsync(await body(await task.value) => value, body? => let value = await task.value; await body(value), makeSameType, makeDiscardable)
    
    // pattern:thenAsyncThrows
    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return try await body(await task.value)
        })
    }
    // endpattern
    
    // generate:thenAsyncThrows(try await body(await task.value) => value, body? => let value = await task.value; try await body(value), makeSameType)

    // GENERATED
    // Generated from then
    // discard?
    public func thenEscaping<U>(_ body: @escaping (T) -> U) -> Guarantee<U> { return then(body) }
    
    // Generated from then
    @discardableResult
    public func then(_ body: @escaping (T) -> ()) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            let value = await task.value; body(value)
            return value
        })
    }
    
    // Generated from then
    @discardableResult
    public func thenEscaping(_ body: @escaping (T) -> ()) -> Self {
        return Self(Task.init {
            let value = await task.value; body(value)
            return value
        })
    }
    
    // Generated from thenThrows
    public func thenEscaping<U>(_ body: @escaping (T) throws -> U) -> Promise<U> { return then(body) }
    
    // Generated from thenThrows
    public func then(_ body: @escaping (T) throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = await task.value; try body(value)
            return value
        })
    }
    
    // Generated from thenThrows
    public func thenEscaping(_ body: @escaping (T) throws -> ()) -> Promise<T> { return then(body) }
    
    // Generated from thenAsync
    @discardableResult
    public func then(_ body: @escaping (T) async -> ()) -> Guarantee<T> {
        return Guarantee<T>(Task.init {
            let value = await task.value; await body(value)
            return value
        })
    }
    
    // Generated from thenAsyncThrows
    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = await task.value; try await body(value)
            return value
        })
    }
    // END GENERATED
}

extension Promise: Thenable {

    // pattern:then
    public func then<U>(_ body: @escaping (T) -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return body(try await task.value)
        })
    }
    // endpattern
    
    // generate:then(makeThenEscapingAlias)
    // generate:then(body(try await task.value) => value, body? => let value = try await task.value; body(value), makeSameType)
    // generate:then(..., makeThenEscapingCopyRenameOnly, Promise<T> => Self)

    // pattern:thenThrows
    public func then<U>(_ body: @escaping (T) throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return try body(try await task.value)
        })
    }
    // endpattern
    
    // generate:thenThrows(makeThenEscapingAlias)
    // generate:thenThrows(try body(try await task.value) => value, body? => let value = try await task.value; try body(value), makeSameType)
    // generate:thenThrows(..., makeThenEscapingAlias)

    // pattern:thenAsync
    public func then<U>(_ body: @escaping (T) async -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return await body(try await task.value)
        })
    }
    // endpattern
    
    // generate:thenAsync(await body(try await task.value) => value, body? => let value = try await task.value; await body(value), makeSameType)

    // pattern:thenAsyncThrows
    public func then<U>(_ body: @escaping (T) async throws -> U) -> Promise<U> {
        return Promise<U>(Task.init {
            // body?
            return try await body(try await task.value)
        })
    }
    // endpattern
    
    // generate:thenAsyncThrows(try await body(try await task.value) => value, body? => let value = try await task.value; try await body(value), makeSameType)

    // GENERATED
    // Generated from then
    public func thenEscaping<U>(_ body: @escaping (T) -> U) -> Promise<U> { return then(body) }
    
    // Generated from then
    public func then(_ body: @escaping (T) -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value; body(value)
            return value
        })
    }
    
    // Generated from then
    public func thenEscaping(_ body: @escaping (T) -> ()) -> Self {
        return Self(Task.init {
            let value = try await task.value; body(value)
            return value
        })
    }
    
    // Generated from thenThrows
    public func thenEscaping<U>(_ body: @escaping (T) throws -> U) -> Promise<U> { return then(body) }
    
    // Generated from thenThrows
    public func then(_ body: @escaping (T) throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value; try body(value)
            return value
        })
    }
    
    // Generated from thenThrows
    public func thenEscaping(_ body: @escaping (T) throws -> ()) -> Promise<T> { return then(body) }
    
    // Generated from thenAsync
    public func then(_ body: @escaping (T) async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value; await body(value)
            return value
        })
    }
    
    // Generated from thenAsyncThrows
    public func then(_ body: @escaping (T) async throws -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let value = try await task.value; try await body(value)
            return value
        })
    }
    // END GENERATED
}
