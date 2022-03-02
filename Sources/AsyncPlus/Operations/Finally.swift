import Foundation

extension ChainableValue {
    
    @discardableResult
    public func finally(_ body: () -> ()) -> NonChainableValue<T> {
        body()
        return NonChainableValue<T>(value)
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> NonChainableGuarantee<T> {
        return NonChainableGuarantee<T>(Task.init {
            await body()
            return value
        })
    }
}

extension CaughtResult {
    
    @discardableResult
    public func finally(_ body: () -> ()) -> NonChainableResult<T> {
        body()
        return NonChainableResult(result)
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> NonChainablePromise<T> {
        return NonChainablePromise<T>(Task.init {
            await body()
            return try result.get()
        })
    }
}

extension ChainableGuarantee {
    
    @discardableResult
    public func finally(_ body: @escaping () -> ()) -> NonChainableGuarantee<T> {
        return NonChainableGuarantee(Task.init {
            let value = await task.value
            body()
            return value
        })
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> NonChainableGuarantee<T> {
        return NonChainableGuarantee(Task.init {
            let value = await task.value
            await body()
            return value
        })
    }
}

extension CaughtPromise {
    
    @discardableResult
    public func finally(_ body: @escaping () -> ()) -> NonChainablePromise<T> {
        return NonChainablePromise(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    @discardableResult
    public func finally(_ body: @escaping () async -> ()) -> NonChainablePromise<T> {
        return NonChainablePromise(Task.init {
            let result = await task.result
            await body()
            return try result.get()
        })
    }
}
