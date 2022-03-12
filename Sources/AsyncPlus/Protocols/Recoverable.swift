import Foundation


public protocol Recoverable: Failable, Thenable {

    associatedtype SelfNonFailable: NonFailable, Thenable
    associatedtype SelfNode: Failable, Thenable

    func recoverEscaping(_ body: @escaping (Error) -> T) -> SelfNonFailable

    func recoverEscaping(_ body: @escaping (Error) throws -> T) -> SelfNode

    func recover(_ body: @escaping (Error) async -> T) -> Guarantee<T>

    func recover(_ body: @escaping (Error) async throws -> T) -> Promise<T>
}

extension Result: Recoverable {

}

extension Promise: Recoverable {

    public func recoverEscaping(_ body: @escaping (Error) -> T) -> Guarantee<T> {
        return recover(body)
    }

    public func recoverEscaping(_ body: @escaping (Error) throws -> T) -> Promise<T> {
        return recover(body)
    }
}
