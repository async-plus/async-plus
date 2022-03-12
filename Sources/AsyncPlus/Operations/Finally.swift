import Foundation

public protocol Finalizable: Node { // where Self: CompletelyCaught OR Self: NonFailable
    
    associatedtype SelfFinalized: Node where SelfFinalized.T == T
    associatedtype SelfAsyncFinalized: Async where SelfAsyncFinalized.T == T
    
    @discardableResult
    func finallyEscaping(_ body: @escaping () -> ()) -> SelfFinalized
    
    @discardableResult
    func finally(_ body: @escaping () async -> ()) -> SelfAsyncFinalized
}

extension ChainableValue: Finalizable {
    
    @discardableResult
    public func finally(_ body: () -> ()) -> FinalizedValue<T> {
        body()
        return FinalizedValue<T>(value)
    }
    
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedValue<T> {
        body()
        return FinalizedValue<T>(value)
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> FinalizedGuarantee<T> {
        return FinalizedGuarantee<T>(Task.init {
            await body()
            return value
        })
    }
}

extension CaughtResult: Finalizable {
    
    @discardableResult
    public func finally(_ body: () -> ()) -> FinalizedResult<T> {
        body()
        return FinalizedResult(result)
    }
    
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedResult<T> {
        body()
        return FinalizedResult(result)
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> FinalizedPromise<T> {
        return FinalizedPromise<T>(Task.init {
            await body()
            return try result.get()
        })
    }
}

extension ChainableGuarantee: Finalizable {
    
    @discardableResult
    public func finally(_ body: @escaping () -> ()) -> FinalizedGuarantee<T> {
        return FinalizedGuarantee(Task.init {
            let value = await task.value
            body()
            return value
        })
    }
    
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedGuarantee<T> {
        return finally(body)
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> FinalizedGuarantee<T> {
        return FinalizedGuarantee(Task.init {
            let value = await task.value
            await body()
            return value
        })
    }
}

extension CaughtPromise: Finalizable {
    
    @discardableResult
    public func finally(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
        return FinalizedPromise(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
        return finally(body)
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> FinalizedPromise<T> {
        return FinalizedPromise(Task.init {
            let result = await task.result
            await body()
            return try result.get()
        })
    }
}
