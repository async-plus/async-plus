# Migrating from PromiseKit

**Similarities**

Below are some PromiseKit operations and their equivalents in Async+:

* `firstly` -> `attempt`
* `then` -> `then` and `thenAttempt` (but it doesn't always need to return a value)
* `map` -> no need? But on the other hand if we are using $0 and wanting to not type annotate then you need it. However it could be the same as `then` just with a different overload for non-async.
* `compactMap` -> extension for optional is called `throwIfNil`. Use this on the optional value.
* `recover` -> `recover`
* `get` -> `then` that doesn't return anything
* `tap` -> `tap` (not implemented yet)
* `ensure` -> `ensure`
* `done` -> `then` 
* `catch` -> only needed for non-throwing contexts. Otherwise you can use use `.asyncThrows()`.
* `finally` -> `finally`



**Differences**

Additionally, these operations offer functionality that is different from PromiseKit:

* `.catch()` with throwing body: this essentially just maps errors to one another.
* `.throws() throws`: If none of the code is async, then we could have a `.throws()` operator.
* `.async() async`: Can use on a guarantee (which is returned by a non-throwing `recover`). Can also use on a catch when the value type is (), as this is the same as a recover.
* `.asyncOptional()`: Async call that returns an optional value of the result.
* `.asyncResult()`: Async call that returns a `Result<T, Error>`
* `.asyncThrows()`: Async call that returns the value or throws.