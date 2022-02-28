# AsyncPlus

A description of this package.


https://discord.gg/vaAhGvvHpW

## Why?
Async/Await is the future of asynchronous coding (not promises, futures, or Rx). Missing a few patterns however. Most notably try/retry, chaining catch calls together.

## Example use cases:
Layer catch behavior for later:
    - Send to analytics
    - Log
Recovery or plan B

## When should a value be passed down the chain?
- `async let value = attempt`: for parallel async code (you then call `let values = await [value, otherValue])`
- `let value = await attempt`
- Besides this case, why should we produce a value? It would only be used otherwise in a "done" block.
Counterexample to above:
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

Different types of contexts:
- Non-throwing, non async
    You need to both catch all errors

- Throwing, non async
- Non-throwing, async
- Throwing, async

How would this be used in each?

*Cancel*

*No need for values*

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

