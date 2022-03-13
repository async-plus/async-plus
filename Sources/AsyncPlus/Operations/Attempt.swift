import Foundation

public func attempt<T>(_ body: () -> T) -> Value<T> {
    return Value(body())
}

public func attempt<T>(_ body: () throws -> T) -> Result<T> {
    do {
        return Result(.success(try body()))
    } catch {
        return Result(.failure(error))
    }
}

public func attempt<T>(_ body: @escaping () async -> T) -> Guarantee<T> {
    return Guarantee(Task.init {
        return await body()
    })
}

public func attempt<T>(_ body: @escaping () async throws -> T) -> Promise<T> {
    return Promise(Task.init {
        try await body()
    })
}
