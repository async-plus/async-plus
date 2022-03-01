# Cancellation

Cancellation is possible through a chained node's exposed `task` property, which returns a `Task<T>` that corresponds to the operation of the node AND all previous nodes in the chain.  This task can then be cancelled using Swift's standard mechanism for cancellation.

You might think that the `task` of a node resulting from `catch` is never run, but tasks always runs regardless of success or failure of the chain of operations.

An alternative implementation exists that creates fewer tasks (one for the entire chain). Please let me know if this is a more favorable implentation for future versions.

Nodes that are instantaneously evaluated do not have a "task", but have a `result` or `value` instead.