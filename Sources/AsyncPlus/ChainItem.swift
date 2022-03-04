import Foundation
import AppKit

public class AnyStageValue<T> {
    
    public let value: T
    
    public required init(_ value: T) {
        self.value = value
    }
}

public class AnyStageResult<T> {
    
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

public class AnyStageGuarantee<T> {
    
    public let task: NonFailableTask<T>
    
    public required init(_ task: NonFailableTask<T>) {
        self.task = task
    }
    
    public func async() async -> T {
        return await task.value
    }
}

public class AnyStagePromise<T> {
    
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

public class ChainableValue<T>: AnyStageValue<T> {}
public class ChainableResult<T>: AnyStageResult<T> {}
public class ChainableGuarantee<T>: AnyStageGuarantee<T> {}
public class ChainablePromise<T>: AnyStagePromise<T> {}

public final class Value<T>: ChainableValue<T> {}
public final class Result<T>: ChainableResult<T> {}
public final class Guarantee<T>: ChainableGuarantee<T> {}
public final class Promise<T>: ChainablePromise<T> {}

public final class PartiallyCaughtResult<T> : ChainableResult<T> {}
public final class CaughtResult<T> : ChainableResult<T> {}
public final class PartiallyCaughtPromise<T> : ChainablePromise<T> {}
public final class CaughtPromise<T> : ChainablePromise<T> {}

public final class NonChainableValue<T> : AnyStageValue<T> {}
public final class NonChainableResult<T> : AnyStageResult<T> {}
public final class NonChainableGuarantee<T> : AnyStageGuarantee<T> {}
public final class NonChainablePromise<T> : AnyStagePromise<T> {}

