import Foundation

// Note: There is no point using `ensure` with a non-failable node (you might as well use `then`). There is also not much of a use case for having an `ensure` operation with a failable body, as it is unclear what the desired behavior here would be for passing on an error.

// Note: No `ensure` function is marked with @discardableResult because `finally` is the preferred way of ending the chain.

extension Ensurable where Self: HasResult, Self: Thenable {

    public func ensure(_ body: @escaping () -> ()) -> Result<T> {
        body()
        return Result<T>(result)
    }

    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

// TODO: Codegen
extension Ensurable where Self: HasResult, Self: PartiallyCaught {

    public func ensure(_ body: @escaping () -> ()) -> PartiallyCaughtResult<T> {
        body()
        return PartiallyCaughtResult<T>(result)
    }

    public func ensure(_ body: @escaping () async -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

// TODO: Codegen
extension Ensurable where Self: HasResult, Self: CompletelyCaught {

    public func ensure(_ body: @escaping () -> ()) -> CaughtResult<T> {
        body()
        return CaughtResult<T>(result)
    }

    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: result)
        })
    }
}

extension Ensurable where Self: HasFailableTask, Self: Thenable {

    public func ensure(_ body: @escaping () -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }

    public func ensure(_ body: @escaping () async -> ()) -> Promise<T> {
        return Promise<T>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

// TODO: Codegen
extension Ensurable where Self: HasFailableTask, Self: PartiallyCaught {

    public func ensure(_ body: @escaping () -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }

    public func ensure(_ body: @escaping () async -> ()) -> PartiallyCaughtPromise<T> {
        return PartiallyCaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

// TODO: Codegen
extension Ensurable where Self: HasFailableTask, Self: CompletelyCaught {

    public func ensure(_ body: @escaping () -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            let result = await task.result
            body()
            return try result.get()
        })
    }

    public func ensure(_ body: @escaping () async -> ()) -> CaughtPromise<T> {
        return CaughtPromise<T>(Task.init {
            return try await ensureAsyncBody(body, result: await task.result)
        })
    }
}

private func ensureAsyncBody<T>(_ body: @escaping () async -> (), result: SimpleResult<T>) async throws -> T {

    await body()
    return try result.get()
}

