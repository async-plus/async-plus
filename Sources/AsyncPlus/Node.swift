import Foundation
import AppKit

public protocol Node {
    associatedtype T
}

public protocol Instant: Node {}
public protocol Async: Node {}

public protocol Failable: Node {}
public protocol NonFailable: Node {}

public protocol Chainable: Node {}
// public protocol Thenable: Chainable {}
public protocol Caught: Chainable {}
public protocol CompletelyCaught: Caught {}
public protocol PartiallyCaught: Caught {}

public protocol HasValue: NonFailable, Instant {
    var value: T { get }
}

public protocol HasResult: Failable, Instant {
    var result: SimpleResult<T> { get }
    init(_ result: SimpleResult<T>)
}

extension HasResult {
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

public protocol HasNonFailableTask: NonFailable, Async {
    var task: NonFailableTask<T> { get }
}

extension HasNonFailableTask {
    public func async() async -> T {
        return await task.value
    }
}

public protocol HasFailableTask: Failable, Async {
    var task: FailableTask<T> { get }
    init(_ task: FailableTask<T>)
}
extension HasFailableTask {
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

public class AnyStageValue<T>: HasValue {
    
    public let value: T
    init(_ value: T) {
        self.value = value
    }
}

public class AnyStageResult<T>: HasResult {

    public let result: SimpleResult<T>
    public required init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public class AnyStageGuarantee<T>: HasNonFailableTask {
    
    public let task: NonFailableTask<T>
    init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

public class AnyStagePromise<T>: HasFailableTask {

    public let task: FailableTask<T>
    public required init(_ task: FailableTask<T>) {
        self.task = task
    }
}

public class ChainableValue<T>: AnyStageValue<T>, Chainable {}
public class ChainableResult<T>: AnyStageResult<T>, Chainable {}
public class ChainableGuarantee<T>: AnyStageGuarantee<T>, Chainable {}
public class ChainablePromise<T>: AnyStagePromise<T>, Chainable {}

public class Value<T>: ChainableValue<T>, Thenable {}
public class Result<T>: ChainableResult<T>, Thenable {}
public class Guarantee<T>: ChainableGuarantee<T>, Thenable {}
public class Promise<T>: ChainablePromise<T>, Thenable {}

public class PartiallyCaughtResult<T>: ChainableResult<T>, PartiallyCaught {}
public class CaughtResult<T>: ChainableResult<T>, CompletelyCaught {}
public class PartiallyCaughtPromise<T>: ChainablePromise<T>, PartiallyCaught {}
public class CaughtPromise<T>: ChainablePromise<T>, CompletelyCaught {}

public class FinalizedValue<T>: AnyStageValue<T> {}
public class FinalizedResult<T>: AnyStageResult<T> {}
public class FinalizedGuarantee<T>: AnyStageGuarantee<T> {}
public class FinalizedPromise<T>: AnyStagePromise<T> {}
