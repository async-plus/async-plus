import Foundation
import AppKit

protocol Node {
    associatedtype T
    associatedtype Fails: FailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

protocol NodeNonFailable: Node where Fails == NeverFails {}
protocol NodeFailable: Node where Fails == Sometimes {}
protocol NodeInstant: Node where When == Instant {}
protocol NodeAsync: Node where When == Async {}

protocol NodeNonFailableInstant: NodeNonFailable, NodeInstant {
    var value: T { get }
}

protocol NodeFailableInstant: NodeFailable, NodeInstant {
    var result: SimpleResult<T> { get }
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
    
    public func asyncResult() async -> SimpleResult<T> {
        return await task.result
    }
}

final class GenericNodeNonFailableInstant<T, Stage: StageFlag>: NodeNonFailableInstant {

    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

final class GenericNodeFailableInstant<T, Stage: StageFlag>: NodeFailableInstant {
    
    let result: SimpleResult<T>
    
    init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

final class GenericNodeNonFailableAsync<T, Stage: StageFlag>: NodeNonFailableAsync {
    
    let task: NonFailableTask<T>
    
    init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

final class GenericNodeFailableAsync<T, Stage: StageFlag>: NodeFailableAsync {
    
    let task: FailableTask<T>

    init(_ task: FailableTask<T>) {
        self.task = task
    }
}

typealias ChainableValue<T> = GenericNodeNonFailableInstant<T, Thenable>
typealias ChainableResult<T> = GenericNodeFailableInstant<T, Thenable>
typealias Guarantee<T> = GenericNodeNonFailableAsync<T, Thenable>
typealias Promise<T> = GenericNodeFailableAsync<T, Thenable>

typealias PartiallyCaughtResult<T> = GenericNodeFailableInstant<T, PartiallyCaught>
typealias CaughtResult<T> = GenericNodeFailableInstant<T, CompletelyCaught>
typealias PartiallyCaughtPromise<T> = GenericNodeFailableAsync<T, PartiallyCaught>
typealias CaughtPromise<T> = GenericNodeFailableAsync<T, CompletelyCaught>

typealias FinalizedValue<T> = GenericNodeNonFailableInstant<T, Finalized>
typealias FinalizedResult<T> = GenericNodeFailableInstant<T, Finalized>
typealias FinalizedGuarantee<T> = GenericNodeNonFailableAsync<T, Finalized>
typealias FinalizedPromise<T> = GenericNodeFailableAsync<T, Finalized>

