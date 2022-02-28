import Foundation


extension NodeFailableInstant where Stage == ResultsStage {
    
    func recover(_ body: (Error) -> T) -> RecoverNonFailableInstant<T> {
        return RecoverNonFailableInstant(body, input: result)
    }

    func recover(_ body: (Error) throws -> T) -> RecoverFailableInstant<T> {
        return RecoverFailableInstant(body, input: result)
    }
    
    func recover(_ body: @escaping (Error) async -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body, input: result)
    }
    
    func recover(_ body: @escaping (Error) async throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body, input: result)
    }
}

extension NodeFailableAsync where Stage == ResultsStage {
    
    // These recover functions are async because the current result is already async.
    func recover(_ body: @escaping (Error) -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body, input: task)
    }
    
    func recover(_ body: @escaping (Error) throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body, input: task)
    }
    
    func recover(_ body: @escaping (Error) async -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body, input: task)
    }
    
    func recover(_ body: @escaping (Error) async throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body, input: task)
    }
}

final class RecoverNonFailableInstant<T>: NodeNonFailableInstant {
    typealias Stage = ResultsStage
    
    let result: T
    
    init(_ body: (Error) -> T, input: SResult<T>) {
        switch input {
        case .success(let value):
            result = value
        case .failure(let error):
            result = body(error)
        }
    }
}

final class RecoverFailableInstant<T>: NodeFailableInstant {
    typealias Stage = ResultsStage
    
    let result: SResult<T>
    
    init(_ body: (Error) throws -> T, input: SResult<T>) {
        switch input {
        case .success(let value):
            result = .success(value)
        case .failure(let errorOriginal):
            do {
                result = .success(try body(errorOriginal))
            } catch {
                // TODO: consider compound error here
                result = .failure(error)
            }
        }
    }
}

final class RecoverNonFailableAsync<T>: NodeNonFailableAsync {
    typealias Stage = ResultsStage
    
    let task: NonFailableTask<T>
    
    private static func sharedInit(_ body: @escaping (Error) async -> T, result: SResult<T>) async -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            // TODO: What to do with previous error
            return await body(error)
        }
    }
    
    init(_ body: @escaping (Error) async -> T, input: FailableTask<T>) {
        task = Task.init {
            await RecoverNonFailableAsync<T>.sharedInit(body, result: await input.result)
        }
    }
    
    init(_ body: @escaping (Error) async -> T, input: SResult<T>) {
        task = Task.init {
            await RecoverNonFailableAsync<T>.sharedInit(body, result: input)
        }
    }
}

final class RecoverFailableAsync<T>: NodeFailableAsync {
    typealias Stage = ResultsStage
    
    let task: FailableTask<T>
    
    private static func sharedInit(_ body: @escaping (Error) async throws -> T, result: SResult<T>) async throws -> T {
            switch result {
            case .success(let value):
                return value
            case .failure(let error):
                // TODO: What to do with previous error
                return try await body(error)
        }
    }
    
    init(_ body: @escaping (Error) async throws -> T, input: FailableTask<T>) {
        task = Task.init {
            try await RecoverFailableAsync<T>.sharedInit(body, result: await input.result)
        }
    }
    
    init(_ body: @escaping (Error) async throws -> T, input: SResult<T>) {
        task = Task.init {
            try await RecoverFailableAsync<T>.sharedInit(body, result: input)
        }
    }
}
