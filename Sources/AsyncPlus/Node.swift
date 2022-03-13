import Foundation
import AppKit

public protocol Node {
    associatedtype T
}

public protocol Instant: Node {}
public protocol Async: Node {}

public protocol Failable: Node {}
public protocol NonFailable: Finalizable {}

public protocol Chainable: Node {}
public protocol CompletelyCaught: Chainable, Finalizable {}
public protocol PartiallyCaught: Chainable {}

public protocol IsValue: NonFailable, Instant {
    var value: T { get }
    init(_ value: T)
}

public protocol IsResult: Failable, Instant {
    var result: SimpleResult<T> { get }
    init(_ result: SimpleResult<T>)
}

extension IsResult {
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

public protocol IsGuarantee: NonFailable, Async {
    var task: NonFailableTask<T> { get }
    init(_ task: NonFailableTask<T>)
}

extension IsGuarantee {
    public func async() async -> T {
        return await task.value
    }
}

public protocol IsPromise: Failable, Async {
    var task: FailableTask<T> { get }
    init(_ task: FailableTask<T>)
    
    func asyncThrows() async throws -> T
    func asyncOptional() async -> T?
    func asyncResult() async -> SimpleResult<T>
}

extension IsPromise {
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

public class BaseValue<T>: IsValue {
    public typealias SelfFinalized = FinalizedValue<T>
    public typealias SelfAsyncFinalized = FinalizedGuarantee<T>
    
    public let value: T
    public required init(_ value: T) {
        self.value = value
    }
}

public class BaseResult<T>: IsResult {
    public typealias SelfFinalized = FinalizedResult<T>
    public typealias SelfAsyncFinalized = FinalizedPromise<T>
    
    public let result: SimpleResult<T>
    public required init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public class BaseGuarantee<T>: IsGuarantee {
    public typealias SelfFinalized = FinalizedGuarantee<T>
    public typealias SelfAsyncFinalized = FinalizedGuarantee<T>
    
    public let task: NonFailableTask<T>
    public required init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

public class BasePromise<T>: IsPromise {
    public typealias SelfFinalized = FinalizedPromise<T>
    public typealias SelfAsyncFinalized = FinalizedPromise<T>
    
    public let task: FailableTask<T>
    public required init(_ task: FailableTask<T>) {
        self.task = task
    }
}

public class ChainableValue<T>: BaseValue<T>, Chainable {}
public class ChainableResult<T>: BaseResult<T>, Chainable {}
public class ChainableGuarantee<T>: BaseGuarantee<T>, Chainable {}
public class ChainablePromise<T>: BasePromise<T>, Chainable {}

public class Value<T>: ChainableValue<T> {}
public class Result<T>: ChainableResult<T> {}
public class Guarantee<T>: ChainableGuarantee<T> {}
public class Promise<T>: ChainablePromise<T> {}

public class PartiallyCaughtResult<T>: ChainableResult<T>, PartiallyCaught {}
public class CaughtResult<T>: ChainableResult<T>, CompletelyCaught {}
public class PartiallyCaughtPromise<T>: ChainablePromise<T>, PartiallyCaught {}
public class CaughtPromise<T>: ChainablePromise<T>, CompletelyCaught {}

public class FinalizedValue<T>: BaseValue<T> {}
public class FinalizedResult<T>: BaseResult<T> {}
public class FinalizedGuarantee<T>: BaseGuarantee<T> {}
public class FinalizedPromise<T>: BasePromise<T> {}
