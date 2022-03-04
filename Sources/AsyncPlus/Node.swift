import Foundation
import AppKit

public protocol Node {
    associatedtype T
    associatedtype Fails: IsFailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

public protocol NonFailable: Node where Fails == NonFailableFlag {}
public protocol Failable: Node where Fails == FailableFlag {}
public protocol Instant: Node where When == InstantFlag {}
public protocol Async: Node where When == AsyncFlag {}

public protocol AnyStageValue: NonFailable, Instant {
    var value: T { get }
}

public protocol AnyStageResult: Failable, Instant {
    var result: SimpleResult<T> { get }
}
extension AnyStageResult {
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

public protocol AnyStageGuarantee: NonFailable, Async {
    var task: NonFailableTask<T> { get }
}
extension AnyStageGuarantee {
    public func async() async -> T {
        return await task.value
    }
}

public protocol AnyStagePromise: Failable, Async {
    var task: FailableTask<T> { get }
}
extension AnyStagePromise {
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

public final class GenericValue<T, Stage: StageFlag>: AnyStageValue {

    public let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

public final class GenericResult<T, Stage: StageFlag>: AnyStageResult {
    
    public let result: SimpleResult<T>
    
    init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public final class GenericGuarantee<T, Stage: StageFlag>: AnyStageGuarantee {
    
    public let task: NonFailableTask<T>
    
    init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

public final class GenericPromise<T, Stage: StageFlag>: AnyStagePromise {
    
    public let task: FailableTask<T>

    init(_ task: FailableTask<T>) {
        self.task = task
    }
}

public typealias Value<T> = GenericValue<T, Thenable>
public typealias Result<T> = GenericResult<T, Thenable>
public typealias Guarantee<T> = GenericGuarantee<T, Thenable>
public typealias Promise<T> = GenericPromise<T, Thenable>

public typealias PartiallyCaughtResult<T> = GenericResult<T, PartiallyCaught>
public typealias CaughtResult<T> = GenericResult<T, CompletelyCaught>
public typealias PartiallyCaughtPromise<T> = GenericPromise<T, PartiallyCaught>
public typealias CaughtPromise<T> = GenericPromise<T, CompletelyCaught>

public typealias FinalizedValue<T> = GenericValue<T, Finalized>
public typealias FinalizedResult<T> = GenericResult<T, Finalized>
public typealias FinalizedGuarantee<T> = GenericGuarantee<T, Finalized>
public typealias FinalizedPromise<T> = GenericPromise<T, Finalized>

