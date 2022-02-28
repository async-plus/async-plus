import Foundation
import AppKit

let backgroundSyncQueue = DispatchQueue(label: "serial-queue")

enum Future<T> {
    case pending
    case resolved(T)
}

protocol Node {
    associatedtype T
    associatedtype Fails: FailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

protocol NodeNonFailable: Node where Fails == Never {}
protocol NodeFailable: Node where Fails == Sometimes {}
protocol NodeInstant: Node where When == Instant {}
protocol NodeAsync: Node where When == Async {}

protocol NodeNonFailableInstant: NodeNonFailable, NodeInstant {
    var result: T { get }
}

protocol NodeFailableInstant: NodeFailable, NodeInstant {
    var result: Result<T> { get }
}

protocol NodeNonFailableAsync: NodeNonFailable, NodeAsync {
    var result: Future<T> { get }
}

protocol NodeFailableAsync: NodeFailable, NodeAsync {
    var result: Future<Result<T>> { get }
}

// START attempt
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
// END attempt

// START Attempt
final class AttemptNonFailableInstant<T>: NodeNonFailableInstant {
    typealias Stage = ResultsStage
    
    let result: T
    
    init(_ body: () -> T) {
        result = body()
    }
}

final class AttemptFailableInstant<T>: NodeFailableInstant {
    typealias Stage = ResultsStage
    
    let result: Result<T>
    
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
    
    // Result is a raw future because Never Async
    var result: Future<T> = .pending
    
    init(_ body: @escaping () async -> T) {
        Task.init {
            result = .resolved(await body())
            // TODO: execute all other items in the chain
        }
    }
}


final class AttemptFailableAsync<T>: NodeFailableAsync {
    typealias Stage = ResultsStage
    
    // Result is a result future because Sometimes Async
    var result: Future<Result<T>> = .pending
    
    init(_ body: @escaping () async throws -> T) {
        Task.init {
            do {
                result = .resolved(.success(try await body()))
            } catch {
                result = .resolved(.failure(error))
            }
            // TODO: Do next in chain
        }
    }
}
// END Attempt

// START recover
extension NodeFailableInstant where Stage == ResultsStage {
    
    func recover(_ body: (Error) -> T) -> RecoverNonFailableInstant<T> {
        return RecoverNonFailableInstant(body, input: result)
    }

    func recover(_ body: (Error) throws -> T) -> RecoverFailableInstant<T> {
        return RecoverFailableInstant(body, input: result)
    }
}

extension NodeFailableAsync where Stage == ResultsStage {
    
    // These recover functions are async because the current result is already async.
    func recover(_ body: @escaping (Error) -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body)
    }
    
    func recover(_ body: @escaping (Error) throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body)
    }
}

extension NodeFailable where Stage == ResultsStage {
    
    func recover(_ body: @escaping (Error) async -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body)
    }
    
    func recover(_ body: @escaping (Error) async throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body)
    }
}
// END recover

// START Recover
final class RecoverNonFailableInstant<T>: NodeNonFailableInstant {
    typealias Stage = ResultsStage
    
    // Result is a raw because Never Instant
    let result: T
    
    init(_ body: (Error) -> T, input: Result<T>) {
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
    
    // Result is a result raw because Sometimes Instant
    let result: Result<T>
    
    init(_ body: (Error) throws -> T, input: Result<T>) {
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
    
    // Result is a raw future because Never Async
    var result: Future<T> = .pending
    let body: (Error) async -> T
    
    init(_ body: @escaping (Error) async -> T) {
        self.body = body
    }
}

final class RecoverFailableAsync<T>: NodeFailableAsync {
    typealias Stage = ResultsStage
    
    // Result is a result future because Sometimes Async
    var result: Future<Result<T>> = .pending
    let body: (Error) async throws -> T
    
    init(_ body: @escaping (Error) async throws -> T) {
        self.body = body
    }
}
// END Recover

// START catch
extension NodeFailableInstant {

    func `catch`(_ body: (Error) -> ()) -> CatchNonFailableInstant<T> {
        // In this case, because there is no throw, there is n
        return CatchNonFailableInstant(body, input: result)
    }

    func `catch`(_ body: (Error) throws -> ()) -> CatchFailableInstant<T> {
        return CatchFailableInstant(body, input: result)
    }
}

extension NodeFailableAsync {

    // These recover functions are async because the current result is already async.
    func `catch`(_ body: @escaping (Error) -> ()) -> CatchNonFailableAsync<T> {
        return CatchNonFailableAsync(body)
    }

    func `catch`(_ body: @escaping (Error) throws -> ()) -> CatchFailableAsync<T> {
        return CatchFailableAsync(body)
    }
}

extension NodeFailable {

    func `catch`(_ body: @escaping (Error) async -> ()) -> CatchNonFailableAsync<T> {
        return CatchNonFailableAsync(body)
    }

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> CatchFailableAsync<T> {
        return CatchFailableAsync(body)
    }
}

// END catch

// START Catch
// Note: the "NonFailable" of the class name indicates whether the operation closure can throw. It is purposefully descended from a "NodeFailable.." because the result can still be a failure: catching errors does not represent a correction of the errors under the hood.

final class CatchNonFailableInstant<T>: NodeFailableInstant {
    typealias Stage = FailuresStage
    
    let result: Result<T>

    init(_ body: (Error) -> (), input: Result<T>) {
        if case .failure(let error) = input {
            body(error)
        }
        result = input
    }
}

final class CatchFailableInstant<T>: NodeFailableInstant {
    typealias Stage = FailuresStage
    let result: Result<T>

    init(_ body: (Error) throws -> (), input: Result<T>) {
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
    
    var result: Future<Result<T>> = .pending
    let body: (Error) async -> ()
    
    init(_ body: @escaping (Error) async -> ()) {
        self.body = body
    }
}

final class CatchFailableAsync<T>: NodeFailableAsync {
    typealias Stage = FailuresStage
    
    var result: Future<Result<T>> = .pending
    let body: (Error) async throws -> ()
    
    init(_ body: @escaping (Error) async throws -> ()) {
        self.body = body
    }
}
// END Catch
