import Foundation
import AppKit

public protocol Node {
    associatedtype T
    associatedtype Fails: IsFailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

public protocol IAnyStageValue: Node where Fails == NonFailableFlag, When == InstantFlag {
    var value: T { get }

}

public protocol IAnyStageResult: Node where Fails == FailableFlag, When == InstantFlag {
    var result: SimpleResult<T> { get }

}
extension IAnyStageResult {
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

public protocol IAnyStageGuarantee: Node where Fails == NonFailableFlag, When == AsyncFlag {
    var task: NonFailableTask<T> { get }


}
extension IAnyStageGuarantee {
    public func async() async -> T {
        return await task.value
    }
}

public protocol IAnyStagePromise: Node where Fails == FailableFlag, When == AsyncFlag {
    var task: FailableTask<T> { get }
}
extension IAnyStagePromise {
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

public class AnyStageValue<T, Stage: StageFlag>: Node {
    public typealias Fails = NonFailableFlag
    public typealias When = InstantFlag
    
    public let value: T
    init(_ value: T) {
        self.value = value
    }
}

public class AnyStageResult<T, Stage: StageFlag>: Node {
    public typealias Fails = FailableFlag
    public typealias When = InstantFlag
    
    public let result: SimpleResult<T>
    init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public class AnyStageGuarantee<T, Stage: StageFlag>: Node {
    public typealias Fails = NonFailableFlag
    public typealias When = AsyncFlag
    
    public let task: NonFailableTask<T>
    init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

public class AnyStagePromise<T, Stage: StageFlag>: Node {
    public typealias Fails = FailableFlag
    public typealias When = AsyncFlag
    
    public let task: FailableTask<T>
    init(_ taskFailable: FailableTask<T>) {
        self.task = taskFailable
    }
}

public typealias Value<T> = AnyStageValue<T, Thenable>
public typealias Result<T> = AnyStageResult<T, Thenable>
public typealias Guarantee<T> = AnyStageGuarantee<T, Thenable>
public typealias Promise<T> = AnyStagePromise<T, Thenable>

public typealias PartiallyCaughtResult<T> = AnyStageResult<T, PartiallyCaught>
public typealias CaughtResult<T> = AnyStageResult<T, CompletelyCaught>
public typealias PartiallyCaughtPromise<T> = AnyStagePromise<T, PartiallyCaught>
public typealias CaughtPromise<T> = AnyStagePromise<T, CompletelyCaught>

public typealias FinalizedValue<T> = AnyStageValue<T, Finalized>
public typealias FinalizedResult<T> = AnyStageResult<T, Finalized>
public typealias FinalizedGuarantee<T> = AnyStageGuarantee<T, Finalized>
public typealias FinalizedPromise<T> = AnyStagePromise<T, Finalized>
