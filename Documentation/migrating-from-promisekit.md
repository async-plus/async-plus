# Migrating from PromiseKit

**Similarities**

Below are some PromiseKit operations and their equivalents in Async+:

* `firstly` -> `attempt`
* `then` -> `then` (but it doesn't always need to return a value)
* `map` -> `then` with a non-async body
* `compactMap` -> use `then` returning a value, combined with a helper extension for optional is called `throwIfNil`. Use this on the optional value when you return to replicate the behavior of `compactMap`.
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
* `.throws() throws`: If the chain is able to be evaluated instantaneously, then this returns the value or throws.
* `.async() async`: Can use on a guarantee (which is returned by a non-throwing `recover`).
* `.asyncOptional()`: For failable async chains: Async call that returns an optional value of the result.
* `.asyncResult()`: Async call that returns a `Result<T, Error>` (`Swift.Result<T, Error>`)
* `.asyncThrows()`: Async call that returns the value or throws.
