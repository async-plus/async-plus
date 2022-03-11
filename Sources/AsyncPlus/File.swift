import Foundation

// TYPE FLAGS
public class StageFlag {}
public class Chainable: StageFlag {}
public final class Thenable: Chainable {}
public final class CompletelyCaught: Chainable {}

// NODE
public protocol Node {
    associatedtype Stage: StageFlag
}

public class AnyStageResult<Stage: StageFlag>: Node {

}

public typealias Result = AnyStageResult<Thenable>
public typealias CaughtResult = AnyStageResult<CompletelyCaught>

// CATCH
public protocol Catchable: Node where Stage: Chainable {
    
    associatedtype SelfCaught: Node where
    SelfCaught.Stage == CompletelyCaught
    
    @discardableResult
    func catchEscaping(_ body: @escaping (Error) -> ()) -> SelfCaught

}

extension AnyStageResult: Catchable where Stage: Chainable {
    public typealias SelfCaught = CaughtResult
    
    @discardableResult
    public func catchEscaping(_ body: @escaping (Error) -> ()) -> CaughtResult {
        
        return CaughtResult()
    }
}

// RECOVER
public protocol Recoverable: Node where Stage == Thenable {

    associatedtype SelfNode: Node where
    SelfNode.Stage == Thenable

    func recoverEscaping(_ body: @escaping (Error) throws -> ()) -> SelfNode
}

// Comment this out for passing build
extension AnyStageResult: Recoverable where Stage == Thenable {

    public func recoverEscaping(_ body: @escaping (Error) throws -> ()) -> Result {
        return Result()
    }
}
