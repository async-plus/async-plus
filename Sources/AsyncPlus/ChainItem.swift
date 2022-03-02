import Foundation
import AppKit

public protocol ChainItem {
    associatedtype T
}

// Protocols for failability
public protocol NonFailable: ChainItem {}
public protocol Failable: ChainItem {}

// Protocols for when results come
public protocol Instant: ChainItem {}
public protocol Async: ChainItem {}

// Protocols for stages of chainability
public protocol Chainable: ChainItem {}
public protocol Thenable: Chainable {}
public protocol Caught: Chainable {}

public class AnyStageValue<T>: NonFailable, Instant {
    
    public let value: T
    
    public required init(_ value: T) {
        self.value = value
    }
}

public class AnyStageResult<T>: Failable, Instant {
    
    public let result: SimpleResult<T>
    
    public required init(_ result: SimpleResult<T>) {
        self.result = result
    }
    
    public func `throws`() throws -> T {
        return try result.get()
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

public class AnyStageGuarantee<T>: NonFailable, Async {
    
    public let task: NonFailableTask<T>
    
    public required init(_ task: NonFailableTask<T>) {
        self.task = task
    }
    
    public func async() async -> T {
        return await task.value
    }
}

public class AnyStagePromise<T>: Failable, Async {
    
    public let task: FailableTask<T>

    public required init(_ task: FailableTask<T>) {
        self.task = task
    }
    
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

