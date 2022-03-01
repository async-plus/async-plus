**Motivation**

Async/Await is the future of asynchronous coding in Swift. Missing a few patterns however. Most notably retry, ensure, making catch calls modular and chainable.

**Full list of commands**

*attempt*

*then*

*recover*

```
let Result<photo> = attempt {
    return await api.getPhoto()
}.recover {
    err in
    return await cache.getPhoto()
}.then {
    photo in
    try displayPhotoToUser(photo)
}
```

*ensure*

*catch*

*finally*



**Example use cases**

Layer catch behavior for later:
    - Send to analytics
        - Log
        Recovery or plan B

**How do I?**

*Run two chains in parallel?*

`async let value = attempt`: for parallel async code (you then call `let values = await [value, otherValue])`

*Use a chain result with `guard` statements?*

```
guard let v: Person? = await attempt {
    return try await api.GetPerson()
}.recover {
    return try await localCache.GetPerson()
}.catch {
    error in
    logger.error("We could not get a person")
}.asyncOptional() else {
    
}
```



**FAQ**

*What is the difference between the `ensure` operation and using Swift's built-in `defer`*

*Why am I getting an unused value error?*

Uncaught errors will raise an "unused result" warning at compile time. Similarly, unused results returned from `then` or `recover` will raise a warning.



**Using chains from async or throwing contexts**

Waiting for a chain to complete

- `let value = await attempt{ ... }.async()` 
- `let value = try await attempt{ ... }.asyncThrows()`

**Migrating from PromiseKit**

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
`.throws() throws`: If none of the code is async, then we could have a `.throws()` operator.
`.async() async`: Can use on a guarantee (which is returned by a non-throwing `recover`). Can also use on a catch when the value type is (), as this is the same as a recover.
`.asyncOptional()`: Async call that returns an optional value of the result.
`.asyncResult()`: Async call that returns a Result
`.asyncThrows()`: Async call that returns the value or throws.