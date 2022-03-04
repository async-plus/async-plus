import Foundation


/// Base class for flags indicating whether the *result* of the operation can be a failure (Not to be confused with whether the closure passed to the operation function e.g. `recover` `catch` etc. can throw).
public class IsFailableFlag {}

/// Flag indicating that the result of the node could never be a failure.
public final class NonFailableFlag: IsFailableFlag {}

/// Flag indicating that the result of the node can sometimes be a failure.
public final class FailableFlag: IsFailableFlag {}


/// Base class for flags indicating whether results are async or instantaneous
public class WhenFlag {}

/// Flag indicating that the result represented by the node is instantaneously available during chaining.
public final class InstantFlag: WhenFlag {}

/// Flag indicating that the result contained in the node is the result of an async operation.
public final class AsyncFlag: WhenFlag {}


/// Base class for flags indicating whether the value has been caught. This indicates what "stage" the value is in with respect to error handling, which is useful for @discardableResult
public class StageFlag {}

/// Flag indicating that operations are still chainable (as opposed to final).
public class Chainable: StageFlag {}

/// Subflag indicating the result is still mutable and can be mapped before it is caught
public final class Thenable: Chainable {}

/// Subflag indicating that catch has been called. After this we allow chaining of fewer operations: only `catch`, `ensure`, and `finally` (`ensure` is allowed in both stages).
public class Caught: Chainable {}

/// Subsubflag indicating that catch operations could have thrown, so there could be unhandled errors
public final class PartiallyCaught: Caught {}

/// Subsubflag indicating that catch operations could not have thrown, so there are no more unhandled errors.
public final class CompletelyCaught: Caught {}

/// Flag indicating that no further node chaining is allowed. Only `.throws` `asyncThrows` etc. calls are allowed.
public final class Finalized: StageFlag {}
