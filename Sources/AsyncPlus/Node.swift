import Foundation
import AppKit

public protocol Node {
    associatedtype T
    associatedtype Fails: IsFailableFlag
    associatedtype When: WhenFlag
    associatedtype Stage: StageFlag
}

public class AnyStageResult<T, Stage: StageFlag>: Node {
    public typealias Fails = FailableFlag
    public typealias When = InstantFlag
    
    public let result: SimpleResult<T>
    init(_ result: SimpleResult<T>) {
        self.result = result
    }
}

public typealias Result<T> = AnyStageResult<T, Thenable>

public typealias PartiallyCaughtResult<T> = AnyStageResult<T, PartiallyCaught>
public typealias CaughtResult<T> = AnyStageResult<T, CompletelyCaught>

public typealias FinalizedResult<T> = AnyStageResult<T, Finalized>
