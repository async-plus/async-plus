import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body, as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of ending the chain.

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SimpleResult<T>) async throws -> T {
    
    await body()
    return try result.get()
}

extension ChainableResult {
    
    public func ensure(_ body: () -> ()) -> Self {
        body()
        return Self(result)
    }
    
    internal func ensureAsyncBodyWithResultType<PromiseType: AnyStagePromise<T>>(_ body: @escaping () async -> (), resultType: PromiseType.Type) -> PromiseType {
        return PromiseType(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension APResult {
    
    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return ensureAsyncBodyWithResultType(body, resultType: Promise<T>.self)
    }
}

extension PartiallyCaughtResult {
    
    public func ensure(_ body: @escaping () async -> ()) -> PartiallyCaughtPromise<T> {
        return ensureAsyncBodyWithResultType(body, resultType: PartiallyCaughtPromise<T>.self)
    }
}

extension CaughtResult {
    
    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return ensureAsyncBodyWithResultType(body, resultType: CaughtPromise<T>.self)
    }
}

extension ChainablePromise {

    public func ensure(_ body: @escaping () -> ()) -> Self {
        return Self(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }

    internal func ensureAsyncBodyWithResultType<PromiseType: AnyStagePromise<T>>(_ body: @escaping () async -> (), resultType: PromiseType.Type) -> PromiseType {
        return PromiseType(Task.init {
            let result = await self.task.result
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension Promise {
    
    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return ensureAsyncBodyWithResultType(body, resultType: Promise<T>.self)
    }
}

extension PartiallyCaughtPromise {
    
    public func ensure(_ body: @escaping () async -> ()) -> PartiallyCaughtPromise<T> {
        return ensureAsyncBodyWithResultType(body, resultType: PartiallyCaughtPromise<T>.self)
    }
}

extension CaughtPromise {
    
    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return ensureAsyncBodyWithResultType(body, resultType: CaughtPromise<T>.self)
    }
}
