import Foundation

public protocol Catchable: Node where Stage: Chainable, Fails == FailableFlag {
    
    associatedtype SelfCaught: Node where
    SelfCaught.T == T,
    SelfCaught.When == When,
    SelfCaught.Fails == Fails,
    SelfCaught.Stage == CompletelyCaught
    
//    associatedtype SelfPartiallyCaught: Node where
//    SelfPartiallyCaught.T == T,
//    SelfPartiallyCaught.When == When,
//    SelfPartiallyCaught.Fails == Fails,
//    SelfPartiallyCaught.Stage == PartiallyCaught
    
    /// `catchEscaping` is just `catch` except slightly less efficient, as it may use an escaping closure where a non-escaping closure would suffice (if the underlying type is a Result)
    @discardableResult
    func catchEscaping(_ body: @escaping (Error) -> ()) -> SelfCaught

//    /// `catchEscaping` is just `catch` except slightly less efficient, as it may use an escaping closure where a non-escaping closure would suffice (if the underlying type is a Result)
//    func catchEscaping(_ body: @escaping (Error) throws -> ()) -> SelfPartiallyCaught
//
//    @discardableResult
//    func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T>
//
//    func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T>
}


//extension AnyStageResult: Catchable where Stage: Chainable {
//    
//    // Implementations of catchEscaping are inside AnyStageResult, because they cannot reuse code due to the differing @escaping status of body, and duplicated code should at least be co-located.
//}

//extension AnyStagePromise: Catchable where Stage: Chainable {
//
//    @discardableResult
//    public func catchEscaping(_ body: @escaping (Error) -> ()) -> CaughtPromise<T> {
//        return self.catch(body)
//    }
//
//    public func catchEscaping(_ body: @escaping (Error) throws -> ()) -> PartiallyCaughtPromise<T> {
//        return self.catch(body)
//    }
//}

