//import Foundation
//
//// Note: For now, ensurable is a separate protocol from Catchable because in the future we may want to allow non-failable chains to use `ensure`.
//
//public protocol Ensurable: Node {
//    
//    associatedtype SelfNode: Node where
//    SelfNode.T == T,
//    SelfNode.When == When,
//    SelfNode.Fails == Fails,
//    SelfNode.Stage == Stage
//    
//    func ensureEscaping(_ body: @escaping () -> ()) -> SelfNode
//
//    func ensure(_ body: @escaping () async -> ()) -> AnyStagePromise<T, Stage>
//}
//
//
//extension AnyStageResult: Ensurable where Stage: Chainable {
//
//    public func ensureEscaping(_ body: @escaping () -> ()) -> AnyStageResult<T, Stage> {
//        return ensure(body)
//    }
//}
//
//extension AnyStagePromise: Ensurable where Stage: Chainable {
//
//    public func ensureEscaping(_ body: @escaping () -> ()) -> AnyStagePromise<T, Stage> {
//        return ensure(body)
//    }
//}
//
//
