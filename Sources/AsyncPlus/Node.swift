import Foundation
import AppKit

public protocol Node {
    associatedtype T
    associatedtype Fails: IsFailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}
//
//public protocol AnyStageValueP: Node where Fails == NonFailableFlag, When == InstantFlag {
//    var value: T { get }
//
//}

//public protocol AnyStageResultP: Node where Fails == FailableFlag, When == InstantFlag {
//    var result: SimpleResult<T> { get }
//
//}
//extension AnyStageResultP {
//    public func `throws`() throws -> T {
//        switch result {
//        case .success(let value):
//            return value
//        case .failure(let error):
//            throw error
//        }
//    }
//
//    public func optional() -> T? {
//        switch result {
//        case .success(let value):
//            return value
//        case .failure(_):
//            return nil
//        }
//    }
//}

//public protocol AnyStageGuaranteeP: Node where Fails == NonFailableFlag, When == AsyncFlag {
//    var task: NonFailableTask<T> { get }
//
//
//}
//extension AnyStageGuaranteeP {
//    public func async() async -> T {
//        return await task.value
//    }
//}

//public protocol AnyStagePromiseP: Node where Fails == FailableFlag, When == AsyncFlag {
//    var taskFailable: FailableTask<T>! { get }
//}
//extension AnyStagePromiseP {
//    public func asyncThrows() async throws -> T {
//        return try await taskFailable.value
//    }
//
//    public func asyncOptional() async -> T? {
//        switch await taskFailable.result {
//        case .success(let value):
//            return value
//        case .failure(_):
//            return nil
//        }
//    }
//
//    public func asyncResult() async -> SimpleResult<T> {
//        return await taskFailable.result
//    }
//}

public class GenericNode<T, Fails: IsFailableFlag, When: WhenFlag, Stage: StageFlag>: Node {
    
    internal let value: T!
    internal let result: SimpleResult<T>!
    internal let task: NonFailableTask<T>!
    public let taskFailable: FailableTask<T>!
    
    init(_ value: T) {
        self.value = value
        result = nil
        task = nil
        taskFailable = nil
    }
    
    init(_ result: SimpleResult<T>) {
        value = nil
        self.result = result
        task = nil
        taskFailable = nil
    }
    
    init(_ task: NonFailableTask<T>) {
        value = nil
        result = nil
        self.task = task
        taskFailable = nil
    }

    init(_ taskFailable: FailableTask<T>) {
        value = nil
        result = nil
        task = nil
        self.taskFailable = taskFailable
    }
}

public class AnyStageValue<T, Stage: StageFlag>: GenericNode<T, NonFailableFlag, InstantFlag, Stage> {}

public class AnyStageResult<T, Stage: StageFlag>: GenericNode<T, FailableFlag, InstantFlag, Stage> {}

public class AnyStageGuarantee<T, Stage: StageFlag>: GenericNode<T, NonFailableFlag, AsyncFlag, Stage> {}

public class AnyStagePromise<T, Stage: StageFlag>: GenericNode<T, FailableFlag, AsyncFlag, Stage> {}

//public typealias AnyStageValue<T, Stage: StageFlag> = GenericNode<T, NonFailableFlag, InstantFlag, Stage>
//
//public typealias AnyStageResult<T, Stage: StageFlag> = GenericNode<T, FailableFlag, InstantFlag, Stage>
//
//public typealias AnyStageGuarantee<T, Stage: StageFlag> = GenericNode<T, NonFailableFlag, AsyncFlag, Stage>
//
//public typealias AnyStagePromise<T, Stage: StageFlag> = GenericNode<T, FailableFlag, AsyncFlag, Stage>

public typealias Value<T> = AnyStageValue<T, Thenable>
public typealias Result<T> = AnyStageResult<T, Thenable>
public typealias Guarantee<T> = AnyStageGuarantee<T, Thenable>
public typealias Promise<T> = AnyStagePromise<T, Thenable>

public typealias PartiallyCaughtResult<T> = AnyStageResult<T, PartiallyCaught>
public typealias CaughtResult<T> = AnyStageResult<T, CompletelyCaught>
public typealias PartiallyCaughtPromise<T> = AnyStagePromise<T, PartiallyCaught>
public typealias CaughtPromise<T> = AnyStagePromise<T, CompletelyCaught>

public typealias FinalizedValue<T> = AnyStageValue<T, Finalized>
public typealias FinalizedResult<T> = AnyStageResult<T, Finalized>
public typealias FinalizedGuarantee<T> = AnyStageGuarantee<T, Finalized>
public typealias FinalizedPromise<T> = AnyStagePromise<T, Finalized>
