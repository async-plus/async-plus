import Foundation

public protocol Finalizable: Node { // where Self: CompletelyCaught OR Self: NonFailable
    
    associatedtype SelfFinalized: Node
    associatedtype SelfAsyncFinalized: Async
    
    @discardableResult
    func finallyEscaping(_ body: @escaping () -> ()) -> SelfFinalized
    
    @discardableResult
    func finally(_ body: @escaping () async -> ()) -> SelfAsyncFinalized
}

extension ChainableValue: Finalizable {
}

extension CaughtResult: Finalizable {
}

extension ChainableGuarantee: Finalizable {
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedGuarantee<T> {
        return finally(body)
    }
}

extension CaughtPromise: Finalizable {
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
        return finally(body)
    }
}
