import Foundation

public protocol Catchable: Node where Stage: Chainable, Fails == FailableFlag {
    
    associatedtype SelfCaught: Node where
    SelfCaught.T == T,
    SelfCaught.When == When,
    SelfCaught.Fails == Fails,
    SelfCaught.Stage == CompletelyCaught
    
    @discardableResult
    func catchEscaping(_ body: @escaping (Error) -> ()) -> SelfCaught

}
