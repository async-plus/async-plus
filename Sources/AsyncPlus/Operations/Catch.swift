import Foundation


// Note: Catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to progagate the error, or chained with another `catch` operation with a non-throwing body.

public protocol Catchable: Node where Stage: Chainable, Fails == FailableFlag {
    @discardableResult
    func `catch`(_ body: @escaping (Error) -> ()) -> GenericNode<T, FailableFlag, When, CompletelyCaught>

    func `catch`(_ body: @escaping (Error) throws -> ()) -> GenericNode<T, FailableFlag, When, PartiallyCaught>
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, CompletelyCaught>

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, PartiallyCaught>
}

//extension GenericNode: Catchable where Fails == FailableFlag, When == InstantFlag, Stage: Chainable {
//    
//    @discardableResult
//    func `catch`(_ body: @escaping (Error) -> ()) -> GenericNode<T, FailableFlag, InstantFlag, CompletelyCaught> {
//        if case .failure(let error) = result {
//            body(error)
//        }
//        return CaughtResult(result)
//    }
//    
//    func `catch`(_ body: @escaping (Error) throws -> ()) -> GenericNode<T, FailableFlag, InstantFlag, PartiallyCaught> {
//        do {
//            if case .failure(let error) = result {
//                try body(error)
//            }
//            return(PartiallyCaughtResult(result))
//        } catch {
//            return PartiallyCaughtResult(.failure(error))
//        }
//    }
//    
//
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
//    
//    @discardableResult
//    public func `catch`(_ body: @escaping (Error) async -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, CompletelyCaught> {
//        return CaughtPromise(Task.init {
//            try await catchAsyncBody(body, result: result)
//        })
//    }
//
//    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, PartiallyCaught> {
//        return PartiallyCaughtPromise(Task.init {
//            try await catchAsyncThrowsBody(body, result: result)
//        })
//    }
//}

extension GenericNode: Catchable where Stage: Chainable, Fails == FailableFlag, When == AsyncFlag  {
    
    
    // These catch functions are async because the current result is already async.
    @discardableResult
    public func `catch`(_ body: @escaping (Error) -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, CompletelyCaught> {
        return CaughtPromise(Task.init {
            switch await taskFailable.result {
            case .success(let value):
                return value
            case .failure(let error):
                body(error)
                throw error
            }
        })
    }

    public func `catch`(_ body: @escaping (Error) throws -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, PartiallyCaught> {
        return PartiallyCaughtPromise(Task.init {
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
    public func `catch`(_ body: @escaping (Error) async -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, CompletelyCaught> {
        return CaughtPromise(Task.init {
            try await catchAsyncBody(body, result: await taskFailable.result)
        })
    }

    public func `catch`(_ body: @escaping (Error) async throws -> ()) -> GenericNode<T, FailableFlag, AsyncFlag, PartiallyCaught> {
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

