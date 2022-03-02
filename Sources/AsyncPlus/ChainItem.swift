import Foundation
import AppKit

public protocol ChainItem {
    associatedtype T
}

public protocol NonFailable: ChainItem {}
public protocol Failable: ChainItem {}
public protocol Instant: ChainItem {}
public protocol Async: ChainItem {}

public protocol AnyValue: NonFailable, Instant {
    var value: T { get }
}

public protocol AnyResult: Failable, Instant {
    var result: SimpleResult<T> { get }
}
extension AnyResult {
    public func `throws`() throws -> T {
        return try result.get()
    }
    
    public func optional() -> T? {
        return result.optional()
    }
}

public protocol AnyGuarantee: NonFailable, Async {
    var task: NonFailableTask<T> { get }
}
extension AnyGuarantee {
    public func async() async -> T {
        return await task.value
    }
}

public protocol AnyPromise: Failable, Async {
    var task: FailableTask<T> { get }
}
extension AnyPromise {
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

// Stages of chainability:
public protocol Chainable {
    
}

public protocol Thenable: Chainable {
    
}

public protocol Caught: Chainable {
    
}

public class AnyStageValue<T>: AnyValue {

    public let value: T
    
    required init(_ value: T) {
        self.value = value
    }
}

public class AnyStageResult<T>: AnyResult {
    
    public let result: SimpleResult<T>
    
    required init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public class AnyStageGuarantee<T>: AnyGuarantee {
    
    public let task: NonFailableTask<T>
    
    required init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

public class AnyStagePromise<T>: AnyPromise {
    
    public let task: FailableTask<T>

    required init(_ task: FailableTask<T>) {
        self.task = task
    }
}

public class ChainableValue<T>: AnyStageValue<T>, Chainable {}
public class ChainableResult<T>: AnyStageResult<T>, Chainable {}
public class ChainableGuarantee<T>: AnyStageGuarantee<T>, Chainable {}
public class ChainablePromise<T>: AnyStagePromise<T>, Chainable {}

public final class Value<T>: ChainableValue<T>, Thenable {}
public final class APResult<T>: ChainableResult<T>, Thenable {}
public final class Guarantee<T>: ChainableGuarantee<T>, Thenable {}
public final class Promise<T>: ChainablePromise<T>, Thenable {}

public final class PartiallyCaughtResult<T> : ChainableResult<T> {}
public final class CaughtResult<T> : ChainableResult<T>, Caught {}
public final class PartiallyCaughtPromise<T> : ChainablePromise<T> {}
public final class CaughtPromise<T> : ChainablePromise<T>, Caught {}

public final class NonChainableValue<T> : AnyStageValue<T> {}
public final class NonChainableResult<T> : AnyStageResult<T> {}
public final class NonChainableGuarantee<T> : AnyStageGuarantee<T> {}
public final class NonChainablePromise<T> : AnyStagePromise<T> {}

