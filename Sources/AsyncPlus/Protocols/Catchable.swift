import Foundation

public protocol Catchable: Failable, Chainable {
    
    associatedtype SelfCaught: CompletelyCaught, Catchable
    associatedtype SelfPartiallyCaught: PartiallyCaught, Catchable
    
    @discardableResult
    func catchEscaping(_ body: @escaping (Error) -> ()) -> SelfCaught
    
    func catchEscaping(_ body: @escaping (Error) throws -> ()) -> SelfPartiallyCaught

    @discardableResult
    func `catch`(_ body: @escaping (Error) async -> ()) -> CaughtPromise<T>

    func `catch`(_ body: @escaping (Error) async throws -> ()) -> PartiallyCaughtPromise<T>
}


extension ChainableResult: Catchable {
    public typealias SelfCaught = CaughtResult<T>
    public typealias SelfPartiallyCaught = PartiallyCaughtResult<T>
}

extension ChainablePromise: Catchable {
    public typealias SelfCaught = CaughtPromise<T>
    public typealias SelfPartiallyCaught = PartiallyCaughtPromise<T>
}

