import Foundation
import AppKit

let backgroundSyncQueue = DispatchQueue(label: "serial-queue")

enum Future<T> {
    case pending
    case resolved(T)
}

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

protocol Node {
    associatedtype T
    associatedtype Fails: ThrowsFlag
    associatedtype When: WhenFlag
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

// RecoverNonFailableInstant
extension NodeFailableInstant {
    
    func recover(_ body: (Error) -> T) -> RecoverNonFailableInstant<T> {
        return RecoverNonFailableInstant(body, input: result)
    }

    func recover(_ body: (Error) throws -> T) -> RecoverFailableInstant<T> {
        return RecoverFailableInstant(body, input: result)
    }
}

extension NodeFailableAsync {
    
    // These recover functions are async because the current result is already async.
    func recover(_ body: @escaping (Error) -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body)
    }
    
    func recover(_ body: @escaping (Error) throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body)
    }
}

extension NodeFailable {
    
    func recover(_ body: @escaping (Error) async -> T) -> RecoverNonFailableAsync<T> {
        return RecoverNonFailableAsync(body)
    }
    
    func recover(_ body: @escaping (Error) async throws -> T) -> RecoverFailableAsync<T> {
        return RecoverFailableAsync(body)
    }
}

class AttemptNonFailableInstant<T>: NodeNonFailableInstant {
    
    var result: T
    
    init(_ body: () -> T) {
        result = body()
    }
}

class AttemptFailableInstant<T>: NodeFailableInstant {
    
    var result: Result<T>
    
    init(_ body: () throws -> T) {
        do {
            result = .success(try body())
        } catch {
            result = .failure(error)
        }
    }
}

class AttemptNonFailableAsync<T>: NodeNonFailableAsync {
    
    // Result is a raw future because Never Async
    var result: Future<T> = .pending
    
    init(_ body: @escaping () async -> T) {
        Task.init {
            result = .resolved(await body())
            // TODO: execute all other items in the chain
        }
    }
}


class AttemptFailableAsync<T>: NodeFailableAsync {
    
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

class RecoverNonFailableInstant<T>: NodeNonFailableInstant {
    
    // Result is a raw because Never Instant
    var result: T
    
    init(_ body: (Error) -> T, input: Result<T>) {
        switch input {
        case .failure(let error):
            result = body(error)
        case .success(let value):
            result = value
        }
    }
}

class RecoverFailableInstant<T>: NodeFailableInstant {
    
    // Result is a result raw because Sometimes Instant
    var result: Result<T>
    
    init(_ body: (Error) throws -> T, input: Result<T>) {
        switch input {
        case .failure(let errorOriginal):
            do {
                result = .success(try body(errorOriginal))
            } catch {
                // TODO: consider compound error here
                result = .failure(error)
            }
        case .success(let value):
            result = .success(value)
        }
    }
}

class RecoverNonFailableAsync<T>: NodeNonFailableAsync {
    
    // Result is a raw future because Never Async
    var result: Future<T> = .pending
    var body: (Error) async -> T
    
    init(_ body: @escaping (Error) async -> T) {
        self.body = body
    }
}

class RecoverFailableAsync<T>: NodeFailableAsync {
    
    // Result is a result future because Sometimes Async
    var result: Future<Result<T>> = .pending
    var body: (Error) async throws -> T
    
    init(_ body: @escaping (Error) async throws -> T) {
        self.body = body
    }
}
