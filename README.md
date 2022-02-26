# AsyncPlus

A description of this package.


https://discord.gg/vaAhGvvHpW

## Why?
Async/Await is the future of asynchronous coding (not promises, futures, or Rx). Missing a few patterns however. Most notably try/retry, chaining catch calls together.

## Example use cases:
Layer catch behavior for later:
    - Send to analytics
    - Log

## Future directions:

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

*Allow async done blocks?*


