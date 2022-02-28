import Foundation

extension NodeNonFailableInstant {
    
    @discardableResult
    func finally(_ body: () -> ()) -> FinalizedValue<T> {
        body()
        return FinalizedValue<T>(value)
    }
}

extension NodeFailableInstant where Stage == CompletelyCaught {
    
    @discardableResult
    func finally(_ body: () -> ()) -> FinalizedResult<T> {
        body()
        return FinalizedResult(result)
    }
}

extension NodeNonFailableAsync {
    
    @discardableResult
    func finally(_ body: () -> ()) -> FinalizedGuarantee<T> {
        body()
        return FinalizedGuarantee(Task.init {
            return await task.value
        })
    }
}

extension NodeFailableAsync where Stage == CompletelyCaught {
    
    @discardableResult
    func finally(_ body: () -> ()) -> FinalizedPromise<T> {
        body()
        return FinalizedPromise(Task.init {
            return try await task.value
        })
    }
}
