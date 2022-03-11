import Foundation

// TYPE FLAGS
public class IsFailableFlag {}
public final class NonFailableFlag: IsFailableFlag {}
public final class FailableFlag: IsFailableFlag {}

public class WhenFlag {}
public final class InstantFlag: WhenFlag {}
public final class AsyncFlag: WhenFlag {}
public class StageFlag {}

public class Chainable: StageFlag {}
public final class Thenable: Chainable {}
public class Caught: Chainable {}
public final class PartiallyCaught: Caught {}
public final class CompletelyCaught: Caught {}
public final class Finalized: StageFlag {}

// NODE
public protocol Node {
    associatedtype T
    associatedtype Fails: IsFailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

public typealias SimpleResult<Success> = Swift.Result<Success, Error>

public class AnyStageResult<T, Stage: StageFlag>: Node {
    public typealias Fails = FailableFlag
    public typealias When = InstantFlag
    
    public let result: SimpleResult<T>
    init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public typealias Result<T> = AnyStageResult<T, Thenable>
public typealias PartiallyCaughtResult<T> = AnyStageResult<T, PartiallyCaught>
public typealias CaughtResult<T> = AnyStageResult<T, CompletelyCaught>
public typealias FinalizedResult<T> = AnyStageResult<T, Finalized>

// CATCH
public protocol Catchable: Node where Stage: Chainable, Fails == FailableFlag {
    
    associatedtype SelfCaught: Node where
    SelfCaught.T == T,
    SelfCaught.When == When,
    SelfCaught.Fails == Fails,
    SelfCaught.Stage == CompletelyCaught
    
    @discardableResult
    func catchEscaping(_ body: @escaping (Error) -> ()) -> SelfCaught

}

extension AnyStageResult: Catchable where Stage: Chainable {
    public typealias SelfCaught = CaughtResult<T>
    
    @discardableResult
    public func catchEscaping(_ body: @escaping (Error) -> ()) -> CaughtResult<T> {
        
        if case .failure(let error) = result {
            body(error)
        }
        return CaughtResult(result)
    }
}

// RECOVER
public protocol Recoverable: Node where Fails == FailableFlag, Stage == Thenable {

    associatedtype SelfNode: Node where
    SelfNode.T == T,
    SelfNode.When == When,
    SelfNode.Fails == FailableFlag,
    SelfNode.Stage == Thenable

    func recoverEscaping(_ body: @escaping (Error) throws -> T) -> SelfNode
}

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
