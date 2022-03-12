import Foundation

protocol Finalizable: Node { // where Stage == CompletelyCaught OR Fails == NonFailableFlag
    
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

extension AnyStagePromise: Finalizable where Stage == CompletelyCaught {
    @discardableResult
    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
        return finally(body)
    }
}
