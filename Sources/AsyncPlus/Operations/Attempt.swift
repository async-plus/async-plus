import Foundation


func attempt<T>(_ body: () -> T) -> AttemptNonFailableInstant<T> {
    return AttemptNonFailableInstant(body)
}

func attempt<T>(_ body: () throws -> T) -> AttemptFailableInstant<T> {
    return AttemptFailableInstant(body)
}

func attempt<T>(_ body: @escaping () async -> T) -> AttemptNonFailableAsync<T> {
    return AttemptNonFailableAsync(body)
}

func attempt<T>(_ body: @escaping () async throws -> T) -> AttemptFailableAsync<T> {
    return AttemptFailableAsync(body)
}

final class AttemptNonFailableInstant<T>: NodeNonFailableInstant {
    typealias Stage = ResultsStage
    
    let result: T
    
    init(_ body: () -> T) {
        result = body()
    }
}

final class AttemptFailableInstant<T>: NodeFailableInstant {
    typealias Stage = ResultsStage
    
    let result: SResult<T>
    
    init(_ body: () throws -> T) {
        do {
            result = .success(try body())
        } catch {
            result = .failure(error)
        }
    }
}

final class AttemptNonFailableAsync<T>: NodeNonFailableAsync {
    typealias Stage = ResultsStage
    
    let task: NonFailableTask<T>
    
    init(_ body: @escaping () async -> T) {
        task = Task.init {
            return await body()
        }
    }
}


final class AttemptFailableAsync<T>: NodeFailableAsync {
    typealias Stage = ResultsStage
    
    let task: FailableTask<T>
    
    init(_ body: @escaping () async throws -> T) {
        task = Task.init {
            try await body()
        }
    }
}
