import Foundation
import AppKit

let backgroundSyncQueue = DispatchQueue(label: "serial-queue")

typealias NonFailableTask<T> = Task<T, Never>
typealias FailableTask<T> = Task<T, Error>

protocol Node {
    associatedtype T
    associatedtype Fails: FailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

protocol NodeNonFailable: Node where Fails == FailsNever {}
protocol NodeFailable: Node where Fails == Sometimes {}
protocol NodeInstant: Node where When == Instant {}
protocol NodeAsync: Node where When == Async {}

protocol NodeNonFailableInstant: NodeNonFailable, NodeInstant {
    var result: T { get }
}
extension NodeNonFailableInstant {
    public var value: T {
        return result
    }
}

protocol NodeFailableInstant: NodeFailable, NodeInstant {
    var result: SResult<T> { get }
}
extension NodeFailableInstant {
    public func `throws`() throws -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
    public func optional() -> T? {
        switch result {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
}

protocol NodeNonFailableAsync: NodeNonFailable, NodeAsync {
    var task: NonFailableTask<T> { get }
}
extension NodeNonFailableAsync {
    public func async() async -> T {
        return await task.value
    }
}

protocol NodeFailableAsync: NodeFailable, NodeAsync {
    var task: FailableTask<T> { get }
}
extension NodeFailableAsync {
    public func asyncThrows() async throws -> T {
        return try await task.value
    }
    
    public func asyncOptional() async -> T? {
        switch await task.result {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
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
// END Attempt

// START recover
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

// END recover

// START Recover
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
// END Recover

// START catch
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
// END catch

// START Catch
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
// END Catch
