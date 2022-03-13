import Foundation

@available(*, unavailable, renamed: "NonFailable")
protocol NodeNonFailable {}

@available(*, unavailable, renamed: "Failable")
protocol NodeFailable {}

@available(*, unavailable, renamed: "Instant")
protocol NodeInstant {}

@available(*, unavailable, renamed: "Async")
protocol NodeAsync {}


@available(*, unavailable, renamed: "IsValue")
protocol NodeNonFailableInstant {}

@available(*, unavailable, renamed: "IsResult")
protocol NodeFailableInstant {}

@available(*, unavailable, renamed: "IsGuarantee")
protocol NodeNonFailableAsync {}

@available(*, unavailable, renamed: "IsPromise")
protocol NodeFailableAsync {}


// These commented-out types have been renamed too, but their place has been taken by a new class. Now "Chainable" literally means you can chain it with something. It does not mean "Thenable" as it did before (confusing).
//@available(*, unavailable, renamed: "Value")
//class ChainableValue {}
//
//@available(*, unavailable, renamed: "Result")
//class ChainableResult {}



