# Motivation and Common Patterns

This section details the motivation for usage of Async+, as well as common patterns the library enables.

## Motivation

Async/await is the future of asynchronous coding in Swift. It's missing a few crucial patterns however. Most notably, patterns such as retrying and ensured execution regardless failure status are unwieldy without promises/futures, and catching behavior is much less modular.  Promise-like chaining with Async+ fix these issues:

**Example: recovery**

```swift
attempt {
    return try await getThing()
}.recover {
    error in
    return try await backupGetThing(error)
}.then {
    thing in
    await thing.doYour()
}.catch {
		error in
    alert(error)
}
```

For comparison, if we tried to write the above flow without Async+ we'd get something like this:


  ```swift
Task.init {
    do {
        let thing: Thing
        do {
            thing = try await getThing()
        } catch {
            thing = try await backupGetThing(error)
        }
        await thing.doYour()
    } catch {
        error in
        alert(error)
    }
}
  ```

Async+ allows async and/or throwing code to remain unnested, modular, and concise. 

**Example: modular failure blocks**

Async+ allows us to easily add catch behavior at any level of a failable operation. For example we could create methods `printingFailure` and `alertingFailure` as follows:

```swift
import AsycPlus

extension Catchable {
    func printingFailure() -> CaughtPromise<T> {
        return self.catchEscaping {
            error in
            print(error.localizedDescription)
        }
    }
    
    func alertingFailure() -> CaughtPromise<T> {
        return self.catchEscaping {
            alert(error.localizedDescription)
        }
    }
}
```

Note that in the protocol context it is more efficient to use `catchEscaping` rather than `catch` when passing a non-async closure, although `catch` would work too. For most cases besides this one it is more effecient to stick with the normal `catch` operation (`catchEscaping` and all other variants of operators with suffix `Escaping` exist because Swift does not allow overloads of the same method with varying @escaping status of a closure).

## Common Patterns

How do I...

***Run two chains in parallel?***

`async let value1 = attempt{ ... }.async()`

`async let value2 = attempt{ ... }.async()`

You then round up the results by calling `let values = await [value1, value2])`

***Use a chained result with `guard` statements?***

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

