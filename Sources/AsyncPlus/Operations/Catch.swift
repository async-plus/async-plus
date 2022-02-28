import Foundation


// Note: catch operations with bodies that are non-throwing are marked with @discardableResult, because all errors are presumably handled. However, if a catch has a throwing body, then an error could still arise. This can be handled with a call to .throws() to progagate the error, or chained with another `catch` operation with a non-throwing body.

extension NodeFailableInstant {

    @discardableResult
    func `catch`(_ body: (Error) -> ()) -> CatchNonFailableInstant<T> {
        // In this case, because there is no throw, there is n
        return CatchNonFailableInstant(body, input: result)
    }

    func `catch`(_ body: (Error) throws -> ()) -> CatchFailableInstant<T> {
        return CatchFailableInstant(body, input: result)
    }
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CatchNonFailableAsync<T> {
        return CatchNonFailableAsync(body, input: result)
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> CatchFailableAsync<T> {
        return CatchFailableAsync(body, input: result)
    }
}

extension NodeFailableAsync {

    // These catch functions are async because the current result is already async.
    @discardableResult
    func `catch`(_ body: @escaping (Error) -> ()) -> CatchNonFailableAsync<T> {
        return CatchNonFailableAsync(body, input: task)
    }

    func `catch`(_ body: @escaping (Error) throws -> ()) -> CatchFailableAsync<T> {
        return CatchFailableAsync(body, input: task)
    }
    
    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CatchNonFailableAsync<T> {
        return CatchNonFailableAsync(body, input: task)
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> CatchFailableAsync<T> {
        return CatchFailableAsync(body, input: task)
    }
}


// Note: the "NonFailable" of the class name indicates whether the operation closure can throw. It is purposefully descended from a "NodeFailable.." because the result can still be a failure: catching errors does not represent a correction of the errors under the hood.

final class CatchNonFailableInstant<T>: NodeFailableInstant {
    typealias Stage = FailuresStage
    
    let result: SResult<T>

    init(_ body: (Error) -> (), input: SResult<T>) {
        if case .failure(let error) = input {
            body(error)
        }
        result = input
    }
}

final class CatchFailableInstant<T>: NodeFailableInstant {
    typealias Stage = FailuresStage
    let result: SResult<T>

    init(_ body: (Error) throws -> (), input: SResult<T>) {
        do {
            if case .failure(let error) = input {
                try body(error)
            }
            result = input
        } catch {
            // TODO: Compound error?
            result = .failure(error)
        }
    }
}

final class CatchNonFailableAsync<T>: NodeFailableAsync {
    typealias Stage = FailuresStage
    
    let task: FailableTask<T>
    
    private static func sharedInit(_ body: @escaping (Error) async -> (), result: SResult<T>) async throws -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            // TODO: What to do with previous error
            await body(error)
            throw error
        }
    }
    
    init(_ body: @escaping (Error) async -> (), input: FailableTask<T>) {
        task = Task.init {
            try await CatchNonFailableAsync<T>.sharedInit(body, result: await input.result)
        }
    }
    
    init(_ body: @escaping (Error) async -> (), input: SResult<T>) {
        task = Task.init {
            try await CatchNonFailableAsync<T>.sharedInit(body, result: input)
        }
    }
}

final class CatchFailableAsync<T>: NodeFailableAsync {
    typealias Stage = FailuresStage
    
    let task: FailableTask<T>
    
    private static func sharedInit(_ body: @escaping (Error) async throws -> (), result: SResult<T>) async throws -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            // TODO: What to do with previous error
            try await body(error)
            throw error
        }
    }
    
    init(_ body: @escaping (Error) async throws -> (), input: FailableTask<T>) {
        task = Task.init {
            try await CatchFailableAsync<T>.sharedInit(body, result: await input.result)
        }
    }
    
    init(_ body: @escaping (Error) async throws -> (), input: SResult<T>) {
        task = Task.init {
            try await CatchFailableAsync<T>.sharedInit(body, result: input)
        }
    }
}

