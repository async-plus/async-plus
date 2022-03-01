<a href="https://discord.gg/vaAhGvvHpW">![async+](Images/github-heading.png)</a>

<p align="center">
  <a href="https://docs.asyncplus.codes/1.0/"><img src="https://img.shields.io/badge/read%20the-docs-blue" alt="Documentation"></a>
  <a href="https://discord.gg/vaAhGvvHpW"><img src="https://img.shields.io/discord/946863161460547684.svg" alt="Team Chat"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License"></a>
  <a href="https://github.com/async-plus/async-plus/actions"><img src="https://github.com/vapor/vapor/workflows/test/badge.svg" alt="Continuous Integration"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/swift-5.5-brightgreen.svg" alt="Swift 5.5"></a>
  <a href="https://twitter.com/async_plus"><img src="https://img.shields.io/badge/twitter-async__plus-5AA9E7.svg" alt="Twitter"></a>
</p>

<br>

Async/Await is the future of asynchronous coding (not promises, futures, or Rx). Missing a few patterns however. Most notably try/retry, chaining catch calls together.



This is an example PR

## Example use cases:

Layer catch behavior for later:
    - Send to analytics
        - Log
        Recovery or plan B

- `async let value = attempt`: for parallel async code (you then call `let values = await [value, otherValue])`
- `let value = await attempt`
```
attempt {
    return await api.getPhoto()
}.recover {
    err in
    return await cache.getPhoto()
}.then {
    photo in
    try displayPhotoToUser(photo)
}.catch {
    err in 
    self.alert(message: err.localizedDescription)
}
```
Alternative to above:
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


## Future directions:

*Cancel*

```
attempt {
    await 
}.recover {
    // Try this thing
}.attempt {
    // No need to have a "done".
}.catch(this error type) {
    // Correct it here
}.finally {
    
}
```

*Value initialization (whole chain is async)*
```
guard let v: Person? = await attempt {
    return try await api.GetPerson()
}.recover {
    return try await localCache.GetPerson()
}.catch {
    error in
    logger.error("We could not get a person")
} else {
    
}
```


### Non-throwing, non-async context:

No ability for throwing call or await. Need to first wrap:

No value:
attempt {
    let x = await call()
    try await anotherCall(x)
}

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

