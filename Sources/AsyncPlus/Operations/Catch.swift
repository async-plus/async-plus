import Foundation


// Note: Catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to progagate the error, or chained with another `catch` operation with a non-throwing body.

public protocol Catchable: Node where Stage: Chainable, Fails == FailableFlag {
    
    associatedtype SelfCaught: Node where
        SelfCaught.T == T,
        SelfCaught.When == When,
        SelfCaught.Fails == Fails,
        SelfCaught.Stage == CompletelyCaught
    
    associatedtype SelfPartiallyCaught: Node where
        SelfPartiallyCaught.T == T,
        SelfPartiallyCaught.When == When,
        SelfPartiallyCaught.Fails == Fails,
        SelfPartiallyCaught.Stage == PartiallyCaught
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) -> ()) -> SelfCaught

    func `catch`(_ body: @escaping (Error) throws -> ()) -> SelfPartiallyCaught
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T>

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T>
}

extension AnyStageResult: Catchable where Stage: Chainable {

//    @discardableResult
//    public func `catch`(_ body: (Error) -> ()) -> CaughtResult<T> {
//        if case .failure(let error) = result {
//            body(error)
//        }
//        return CaughtResult(result)
//    }
//
//    public func `catch`(_ body: (Error) throws -> ()) -> PartiallyCaughtResult<T> {
//        do {
//            if case .failure(let error) = result {
//                try body(error)
//            }
//            return(PartiallyCaughtResult(result))
//        } catch {
//            return PartiallyCaughtResult(.failure(error))
//        }
//    }

    @discardableResult
    public func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: result)
        })
    }

    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: result)
        })
    }
    
    // For protocol conformance:
    @discardableResult
    public func `catch`(_ body: @escaping (Error) -> ()) -> CaughtResult<T> {
        if case .failure(let error) = result {
            body(error)
        }
        return CaughtResult(result)
    }

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
}

extension AnyStagePromise: Catchable where Stage: Chainable  {

    @discardableResult
    public func `catch`(_ body: @escaping (Error) -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            switch await taskFailable.result {
            case .success(let value):
                return value
            case .failure(let error):
                body(error)
                throw error
            }
        })
    }

    public func `catch`(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            switch await taskFailable.result {
            case .success(let value):
                return value
            case .failure(let error):
                try body(error)
                throw error
            }
        })
    }

    @discardableResult
    public func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: await taskFailable.result)
        })
    }

    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise(Task.init {
            try await catchAsyncThrowsBody(body, result: await taskFailable.result)
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
        try await body(error)
        throw error
    }
}

