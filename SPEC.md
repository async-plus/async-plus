# SPEC

### Non-throwing, non-async context:

No ability for throwing call or await. Need to first wrap:

No value:
attempt {
    let x = await call()
    try await anotherCall(x)
}

throwing, non-async context:

TODO: Are these type "flags" necessary? Why not just make the base types conform to the stage flag?

## Migrating from PromiseKit
`firstly` -> `attempt`
`then` -> `then` and `thenAttempt` (but it doesn't always need to return a value)
`map` -> no need? But on the other hand if we are using $0 and wanting to not type annotate then you need it. However it could be the same as `then` just with a different overload for non-async.
`compactMap` -> extension for optional "throwing if nil"
`recover` -> `recover`. Needed.
`get` -> `then` that doesn't return anything
`tap` -> `tap`
`ensure` -> `ensure`
`done` -> `then` only needed if map is needed. Cannot call `asyncOptional` or `promise` on this.
`catch` -> only needed for non-throwing contexts. Otherwise use `.asyncThrows()`.
`finally` -> `finally`

We add these new operations:
`.catch()` with throwing body: this essentially just maps errors to one another.
`.throws() throws`: TODO: If none of the code is async, then we could have a `.throws()` operator.
`.async() async`: Can use on a guarantee (which is returned by a non-throwing `recover`). Can also use on a catch when the value type is (), as this is the same as a recover.
`.asyncOptional()`: Async call that returns an optional value of the result.
`.asyncResult()`: Async call that returns a Result
`.asyncThrows()`: Async call that returns the value or throws.
`.promise`: Can call if you have not called `done`.
`.future`: returns a Combine Future for the operation

