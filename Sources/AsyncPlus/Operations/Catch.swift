import Foundation

// Note: Catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to propagate the error, or chained with another `catch` operation with a non-throwing body.

public protocol Catchable: Ensurable {
    
    associatedtype SelfCaught: CompletelyCaught, Catchable
    associatedtype SelfPartiallyCaught: PartiallyCaught, Catchable
    
    @discardableResult
    func catchEscaping(_ body: @escaping (Error) -> ()) -> SelfCaught
    
    func catchEscaping(_ body: @escaping (Error) throws -> ()) -> SelfPartiallyCaught

    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T>

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T>
}

extension Catchable where Self: IsResult {
    
    // pattern:catch
    @discardableResult
	public func `catch`(_ body: @escaping (Error) -> ()) -> CaughtResult<T> {
        if case .failure(let error) = result {
            body(error)
        }
        return CaughtResult(result)
    }
    // endpattern
    
    // generate:catch(func `catch` => func catchEscaping, makeEscaping)

    // pattern:catchThrows
	public func `catch`(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtResult<T> {
        do {
            if case .failure(let error) = result {
                try body(error)
            }
            return(PartiallyCaughtResult(result))
        } catch {
            return PartiallyCaughtResult(.failure(error))
        }
    }
    // endpattern
    
    // generate:catchThrows(func `catch` => func catchEscaping, makeEscaping)

    @discardableResult
    public func `catch`(_ body: @escaping (Error) async /*safe*/ -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: result)
        })
    }

    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: result)
        })
    }
    
    // GENERATED
    // Generated from catch
    @discardableResult
    public func catchEscaping(_ body: @escaping (Error) -> ()) -> CaughtResult<T> {
        if case .failure(let error) = result {
            body(error)
        }
        return CaughtResult(result)
    }
    
    // Generated from catchThrows
    public func catchEscaping(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtResult<T> {
        do {
            if case .failure(let error) = result {
                try body(error)
            }
            return(PartiallyCaughtResult(result))
        } catch {
            return PartiallyCaughtResult(.failure(error))
        }
    }
    // END GENERATED
}

extension ChainableResult {
    public typealias SelfCaught = CaughtResult<T>
    public typealias SelfPartiallyCaught = PartiallyCaughtResult<T>
}

extension Result: Catchable {}
extension PartiallyCaughtResult: Catchable {}
extension CaughtResult: Catchable {}


extension Catchable where Self: IsPromise {

    @discardableResult
    public func `catch`(_ body: @escaping (Error) -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let error):
                body(error)
                throw error
            }
        })
    }
    
    @discardableResult
    public func catchEscaping(_ body: @escaping (Error) -> ()) -> CaughtPromise<T> {
        return self.catch(body)
    }

    public func `catch`(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            switch await task.result {
            case .success(let value):
                return value
            case .failure(let error):
                try body(error)
                throw error
            }
        })
    }

    public func catchEscaping(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtPromise<T> {
        return self.catch(body)
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

extension ChainablePromise {
    public typealias SelfCaught = CaughtPromise<T>
    public typealias SelfPartiallyCaught = PartiallyCaughtPromise<T>
}

extension Promise: Catchable {}
extension PartiallyCaughtPromise: Catchable {}
extension CaughtPromise: Catchable {}

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
