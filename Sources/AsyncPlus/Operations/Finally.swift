import Foundation

extension NodeNonFailableInstant {
    
    @discardableResult
    func finally(_ body: () -> ()) -> FinalizedValue<T> {
        body()
        return FinalizedValue<T>(value)
    }
    
    @discardableResult
    func finally(_ body: @escaping () async -> ()) -> FinalizedGuarantee<T> {
        return FinalizedGuarantee<T>(Task.init {
            await body()
            return value
        })
    }
}

extension NodeFailableInstant where Stage == CompletelyCaught {
    
    @discardableResult
    func finally(_ body: () -> ()) -> FinalizedResult<T> {
        body()
        return FinalizedResult(result)
    }
    
    @discardableResult
    func finally(_ body: @escaping () async -> ()) -> FinalizedPromise<T> {
        return FinalizedPromise<T>(Task.init {
            await body()
            return try result.get()
        })
    }
}

extension NodeNonFailableAsync {
    
    @discardableResult
    func finally(_ body: @escaping () -> ()) -> FinalizedGuarantee<T> {
        return FinalizedGuarantee(Task.init {
            let value = await task.value
            body()
            return value
        })
    }
    
    @discardableResult
    func finally(_ body: @escaping () async -> ()) -> FinalizedGuarantee<T> {
        return FinalizedGuarantee(Task.init {
            let value = await task.value
            await body()
            return value
        })
    }
}

extension NodeFailableAsync where Stage == CompletelyCaught {
    
    @discardableResult
    func finally(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
        return FinalizedPromise(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }
    
    @discardableResult
    func finally(_ body: @escaping () async -> ()) -> FinalizedPromise<T> {
        return FinalizedPromise(Task.init {
            let result = await task.result
            await body()
            return try result.get()
        })
    }
}
