import Foundation
import AppKit

// TODO: If T is () and Fails is NeverFails, then the result is discardable

protocol Node {
    associatedtype T
    associatedtype Fails: FailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

protocol NodeNonFailable: Node where Fails == NeverFails {}
protocol NodeFailable: Node where Fails == Sometimes {}
protocol NodeInstant: Node where When == Instant {}
protocol NodeAsync: Node where When == Async {}

protocol NodeNonFailableInstant: NodeNonFailable, NodeInstant {
    var result: T { get }
}
extension NodeNonFailableInstant {
    public var value: T {
        return result
    }
}

protocol NodeFailableInstant: NodeFailable, NodeInstant {
    var result: SResult<T> { get }
}
extension NodeFailableInstant {
    public func `throws`() throws -> T {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
    public func optional() -> T? {
        switch result {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
}

protocol NodeNonFailableAsync: NodeNonFailable, NodeAsync {
    var task: NonFailableTask<T> { get }
}
extension NodeNonFailableAsync {
    public func async() async -> T {
        return await task.value
    }
}

protocol NodeFailableAsync: NodeFailable, NodeAsync {
    var task: FailableTask<T> { get }
}
extension NodeFailableAsync {
    public func asyncThrows() async throws -> T {
        return try await task.value
    }
    
    public func asyncOptional() async -> T? {
        switch await task.result {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
    
    public func asyncResult() async -> SResult<T> {
        return await task.result
    }
}


final class ChainableValue<T>: NodeNonFailableInstant {
    typealias Stage = ResultsStage
    
    let result: T
    
    init(_ value: T) {
        self.result = value
    }
}

final class ChainableResult<T>: NodeFailableInstant {
    typealias Stage = ResultsStage
    
    let result: SResult<T>
    
    init(_ result: SResult<T>) {
        self.result = result
    }
}

final class Guarantee<T>: NodeNonFailableAsync {
    typealias Stage = ResultsStage
    
    let task: NonFailableTask<T>
    
    init(_ task: NonFailableTask<T>) {
        self.task = task
    }
}

final class Promise<T>: NodeFailableAsync {
    typealias Stage = ResultsStage
    
    let task: FailableTask<T>
    
    init(_ task: FailableTask<T>) {
        self.task = task
    }
}

final class CatchableResult<T>: NodeFailableInstant {
    typealias Stage = FailuresStage
    
    let result: SResult<T>

    init(_ result: SResult<T>) {
        self.result = result
    }
}

final class CatchablePromise<T>: NodeFailableAsync {
    typealias Stage = FailuresStage
    
    let task: FailableTask<T>

    init(_ task: FailableTask<T>) {
        self.task = task
    }
}
