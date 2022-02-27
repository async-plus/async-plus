import Foundation
import AppKit

let backgroundSyncQueue = DispatchQueue(label: "serial-queue")

func attempt<T>(_ body: () -> T) -> Attempt<T> {
    return Attempt(body)
}

func attempt<T>(_ body: () throws -> T) -> AttemptThrows<T> {
    return AttemptThrows(body)
}

func attempt<T>(_ body: @escaping () async -> T) -> AttemptAsync<T> {
    return AttemptAsync(body)
}

func attempt<T>(_ body: @escaping () async throws -> T) -> AttemptAsyncThrows<T> {
    return AttemptAsyncThrows(body)
}

protocol Promise {
    associatedtype T
    associatedtype Fails
    associatedtype When
}

class Attempt<T>: Promise {
    
    typealias Fails = Never
    typealias When = Instant
    
    // Result is raw because Never, Instant
    var result: T
    
    init(_ body: () -> T) {
        result = body()
    }
    
    // no need for recover because Fails = Never
}

class AttemptThrows<T>: Promise {
    
    typealias Fails = Sometimes
    typealias When = Instant
    
    // Result is result because Sometimes, Instant
    var result: Result<T>
    
    init(_ body: () throws -> T) {
        do {
            result = .success(try body())
        } catch {
            result = .failure(error)
        }
    }
    
    // Implementing recover because Fails = Somtimes
    func recover(_ body: @escaping (Error) async -> T) -> RecoverAsync<T> {
        return RecoverAsync(body)
    }
    
    func recover(_ body: @escaping (Error) async throws -> T) -> RecoverAsyncThrows<T> {
        return RecoverAsyncThrows(body)
    }
    
    // Non-escaping because Result = Instant
    func recover(_ body: (Error) -> T) -> Recover<T> {
        return Recover(body, input: result)
    }
    
    // Non-escaping because Result = Instant
    func recover(_ body: (Error) throws -> T) -> RecoverThrows<T> {
        return RecoverThrows(body, input: result)
    }
}

enum Future<T> {
    case pending
    case resolved(T)
}

class AttemptAsync<T>: Promise {
    
    typealias Fails = Never
    typealias When = Async
    
    // Result is a raw future because Never Async
    var result: Future<T> = .pending
    
    init(_ body: @escaping () async -> T) {
        Task.init {
            result = .resolved(await body())
            // TODO: execute all other items in the chain
        }
    }
    
    // Not implementing recover because Fails = never
}


class AttemptAsyncThrows<T>: Promise {
    
    typealias Fails = Sometimes
    typealias When = Async
    
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
    
    // Implementing recover because Fails = Somtimes
    // We return a RecoverAsync because
    func recover(_ body: @escaping (Error) -> T) -> RecoverAsync<T> {
        // However
        return RecoverAsync(body)
    }
    
    func recover(_ body: @escaping (Error) throws -> T) -> RecoverAsyncThrows<T> {
        return RecoverAsyncThrows(body)
    }
    
    func recover(_ body: @escaping (Error) async -> T) -> RecoverAsync<T> {
        return RecoverAsync(body)
    }
    
    func recover(_ body: @escaping (Error) async throws -> T) -> RecoverAsyncThrows<T> {
        return RecoverAsyncThrows(body)
    }
}

class Recover<T>: Promise {
    
    typealias Fails = Never
    typealias When = Instant
    
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

class RecoverThrows<T>: Promise {
    
    typealias Fails = Sometimes
    typealias When = Instant
    
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

class RecoverAsync<T>: Promise {
    
    typealias Fails = Never
    typealias When = Async
    
    // Result is a raw future because Never Async
    var result: Future<T> = .pending
    var body: (Error) async -> T
    
    init(_ body: @escaping (Error) async -> T) {
        self.body = body
    }
}

class RecoverAsyncThrows<T>: Promise {
    
    typealias Fails = Sometimes
    typealias When = Async
    
    // Result is a result future because Sometimes Async
    var result: Future<Result<T>> = .pending
    var body: (Error) async throws -> T
    
    init(_ body: @escaping (Error) async throws -> T) {
        self.body = body
    }
}
