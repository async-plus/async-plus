//import Foundation
//
//protocol Finalizable: Node { // where Stage == CompletelyCaught OR Fails == NonFailableFlag
//    
//    associatedtype SelfFinalized: Node where
//    SelfFinalized.T == T,
//    SelfFinalized.When == When,
//    SelfFinalized.Fails == Fails,
//    SelfFinalized.Stage == Finalized
//    
//    associatedtype SelfAsyncFinalized: Node where
//    SelfAsyncFinalized.T == T,
//    SelfAsyncFinalized.When == AsyncFlag,
//    SelfAsyncFinalized.Fails == Fails,
//    SelfAsyncFinalized.Stage == Finalized
//    
//    @discardableResult
//    func finallyEscaping(_ body: @escaping () -> ()) -> SelfFinalized
//    
//    @discardableResult
//    func finally(_ body: @escaping () async -> ()) -> SelfAsyncFinalized
//}
//
//extension AnyStageValue: Finalizable {
//}
//
//extension AnyStageResult: Finalizable where Stage == CompletelyCaught {
//}
//
//extension AnyStageGuarantee: Finalizable {
//    @discardableResult
//    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedGuarantee<T> {
//        return finally(body)
//    }
//}
//
//extension AnyStagePromise: Finalizable where Stage == CompletelyCaught {
//    @discardableResult
//    public func finallyEscaping(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
//        return finally(body)
//    }
//}
