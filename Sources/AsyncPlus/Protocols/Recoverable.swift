import Foundation

// Note: Specializing these protocols doesn't appear to work: see potential bug in Swift in the have-i-found-a-bug-in-swift branch

public protocol Recoverable: Node {

    associatedtype SelfNonFailable: Node where
    SelfNonFailable.T == T,
    SelfNonFailable.When == When,
    SelfNonFailable.Fails == NonFailableFlag,
    SelfNonFailable.Stage == Thenable

    associatedtype SelfNode: Node where
    SelfNode.T == T,
    SelfNode.When == When,
    SelfNode.Fails == FailableFlag,
    SelfNode.Stage == Thenable

    associatedtype SelfNonFailableAsync: Node where
    SelfNonFailableAsync.T == T,
    SelfNonFailableAsync.When == AsyncFlag,
    SelfNonFailableAsync.Fails == NonFailableFlag,
    SelfNonFailableAsync.Stage == Thenable

    associatedtype SelfAsync: Node where
    SelfAsync.T == T,
    SelfAsync.When == AsyncFlag,
    SelfAsync.Fails == FailableFlag,
    SelfAsync.Stage == Thenable

    func recoverEscaping(_ body: @escaping (Error) -> T) -> SelfNonFailable

    func recoverEscaping(_ body: @escaping (Error) throws -> T) -> SelfNode

    func recover(_ body: @escaping (Error) async -> T) -> SelfNonFailableAsync

    func recover(_ body: @escaping (Error) async throws -> T) -> SelfAsync
}

extension AnyStageResult: Recoverable where Stage == Thenable {

    
    
}

//extension AnyStagePromise: Recoverable where Stage == Thenable {
//
//    public func recoverEscaping(_ body: @escaping (Error) -> T) -> Guarantee<T> {
//        return recover(body)
//    }
//
//    public func recoverEscaping(_ body: @escaping (Error) throws -> T) -> Promise<T> {
//        return recover(body)
//    }
//}
