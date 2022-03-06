# Cancellation

Cancellation is possible through a chained item's exposed `task` property, which returns a `Task<T>` that corresponds to the operation of the chain item AND all previous items in the chain.  This task can then be cancelled using Swift's standard mechanism for cancellation.

You might think that the `task` of a chained item resulting from `catch` is never run, but tasks always runs regardless of success or failure of the chain of operations.

An alternative implementation exists that creates fewer tasks (one for the entire chain). Please let me know if this is a more favorable implentation for future versions.

Chained items that are instantaneously evaluated do not have a "task", but have a `result` or `value` instead.
