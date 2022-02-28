import Foundation


func attempt<T>(_ body: () -> T) -> ChainableValue<T> {
    return ChainableValue(body())
}

func attempt<T>(_ body: () throws -> T) -> ChainableResult<T> {
    do {
        return ChainableResult(.success(try body()))
    } catch {
        return ChainableResult(.failure(error))
    }
}

func attempt<T>(_ body: @escaping () async -> T) -> Guarantee<T> {
    return Guarantee(Task.init {
        return await body()
    })
}

func attempt<T>(_ body: @escaping () async throws -> T) -> Promise<T> {
    return Promise(Task.init {
        try await body()
    })
}
