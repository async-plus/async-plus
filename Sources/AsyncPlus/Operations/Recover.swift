import Foundation

// Note: When you are using recover and T is void or (), then either 1) You are intending to stack on further operations after the correction, or 2) you could have used `catch`. For this reason, there are no @discardableResult recover functions. For this use case, catch should be used.

extension AnyStageResult: Recoverable where Stage == Thenable {

    public func recoverEscaping(_ body: @escaping (Error) throws -> T) -> Result<T> {
        switch result {
        case .success(let value):
            return Result(.success(value))
        case .failure(let errorOriginal):
            do {
                return Result(.success(try body(errorOriginal)))
            } catch {
                return Result(.failure(error))
            }
        }
    }
}
