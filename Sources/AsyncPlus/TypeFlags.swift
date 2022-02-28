import Foundation


/// Base class for flags indicating whether the *result* of the operation can be a failure (Not to be confused with whether the closure passed to the operation function e.g. `recover` `catch` etc. can throw).
class FailableFlag {}

/// Flag indicating that the result of the node could never be a failure.
final class Never: FailableFlag {}

/// Flag indicating that the result of the node can sometimes be a failure.
final class Sometimes: FailableFlag {}


/// Base class for flags indicating whether results are async or instantaneous
class WhenFlag {}

/// Flag indicating that the result represented by the node is instantaneously available during chaining.
final class Instant: WhenFlag {}

/// Flag indicating that the result contained in the node is the result of an async operation.
final class Async: WhenFlag {}


/// Base class for flags indicating the stage of results along the chain. There are two stages: a results-oriented stage for the beginning, and a failure-catching-oriented stage for the end of the chain.
class StageFlag {}

/// Flag indicating the first stage of chained node operations that allows `thenAttempt` and `recover` operations
final class ResultsStage: StageFlag {}

/// Flag indicating the later stage that allows fewer operations: only `catch`, `ensure`, and `finally` (`ensure` is allowed in both stages).
final class FailuresStage: StageFlag {}
