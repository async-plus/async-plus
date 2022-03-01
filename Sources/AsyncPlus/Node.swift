import Foundation
import AppKit

public protocol Node {
    associatedtype T
    associatedtype Fails: FailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

public protocol NodeNonFailable: Node where Fails == NeverFails {}
public protocol NodeFailable: Node where Fails == Sometimes {}
public protocol NodeInstant: Node where When == Instant {}
public protocol NodeAsync: Node where When == Async {}

public protocol NodeNonFailableInstant: NodeNonFailable, NodeInstant {
    var value: T { get }
}

public protocol NodeFailableInstant: NodeFailable, NodeInstant {
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

public protocol NodeNonFailableAsync: NodeNonFailable, NodeAsync {
    var task: NonFailableTask<T> { get }
}
extension NodeNonFailableAsync {
    public func async() async -> T {
        return await task.value
    }
}

public protocol NodeFailableAsync: NodeFailable, NodeAsync {
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

public final class GenericNodeNonFailableInstant<T, Stage: StageFlag>: NodeNonFailableInstant {

    public let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

public final class GenericNodeFailableInstant<T, Stage: StageFlag>: NodeFailableInstant {
    
    public let result: SimpleResult<T>
    
    init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public final class GenericNodeNonFailableAsync<T, Stage: StageFlag>: NodeNonFailableAsync {
    
    public let task: NonFailableTask<T>
    
    init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

public final class GenericNodeFailableAsync<T, Stage: StageFlag>: NodeFailableAsync {
    
    public let task: FailableTask<T>

    init(_ task: FailableTask<T>) {
        self.task = task
    }
}

public typealias ChainableValue<T> = GenericNodeNonFailableInstant<T, Thenable>
public typealias ChainableResult<T> = GenericNodeFailableInstant<T, Thenable>
public typealias Guarantee<T> = GenericNodeNonFailableAsync<T, Thenable>
public typealias Promise<T> = GenericNodeFailableAsync<T, Thenable>

public typealias PartiallyCaughtResult<T> = GenericNodeFailableInstant<T, PartiallyCaught>
public typealias CaughtResult<T> = GenericNodeFailableInstant<T, CompletelyCaught>
public typealias PartiallyCaughtPromise<T> = GenericNodeFailableAsync<T, PartiallyCaught>
public typealias CaughtPromise<T> = GenericNodeFailableAsync<T, CompletelyCaught>

public typealias FinalizedValue<T> = GenericNodeNonFailableInstant<T, Finalized>
public typealias FinalizedResult<T> = GenericNodeFailableInstant<T, Finalized>
public typealias FinalizedGuarantee<T> = GenericNodeNonFailableAsync<T, Finalized>
public typealias FinalizedPromise<T> = GenericNodeFailableAsync<T, Finalized>

