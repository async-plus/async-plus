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
