import Foundation

/// Base class for flags indicating whether the value has been caught. This indicates what "stage" the value is in with respect to error handling, which is useful for @discardableResult
//public class StageFlag {}
//
///// Flag indicating that operations are still chainable (as opposed to final).
//public class Chainable: StageFlag {}
//
///// Subflag indicating the result is still mutable and can be mapped before it is caught
//public final class Thenable: Chainable {}
//
///// Subflag indicating that catch has been called. After this we allow chaining of fewer operations: only `catch`, `ensure`, and `finally` (`ensure` is allowed in both stages).
//public class Caught: Chainable {}
//
///// Subsubflag indicating that catch operations could have thrown, so there could be unhandled errors
//public final class PartiallyCaught: Caught {}
//
///// Subsubflag indicating that catch operations could not have thrown, so there are no more unhandled errors.
//public final class CompletelyCaught: Caught {}
//
///// Flag indicating that no further node chaining is allowed. Only `.throws` `asyncThrows` etc. calls are allowed.
//public final class NonChainable: StageFlag {}
