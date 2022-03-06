# Operations

Following is a full list of supported chaining operations in Async+:

**attempt**
Use `attempt` to start a chain of commands. The provided body will begin running immediately. The return type will be a `Value`, `Result` (`AsyncPlus.Result`), `Guarantee`, or `Promise` depending on the async/throwing status of the body closure.

```swift
attempt {
    <body>
}
```

**then**
`then` takes a body closure to run that takes as input any results from earlier in the chain, and returns a value to pass along to later operations in the chain. The body closure can be async and/or throwing. If the closure does not return a value, any existing values from earlier in the chain are passed on automatically.

```swift
.then {
    upstreamResult in
    <body>
}
```

or

```swift
.then {
    upstreamResult -> OutType in
    <body>
    return <instance of OutType>
}
```

**recover**
The provided closure to recover recieves any errors, and can attempt to provide a "backup" or "recovery" value to fix the error. The provided closure may be async and/or throwing.

Example using `attempt`, `then`, and `recover`:
```swift
let photo = try await attempt {
    return await api.getPhoto()
}.recover {
    err in
    return await cache.getPhoto()
}.then {
    photo in
    try displayPhotoToUser(photo)
}.asyncThrows()
```

**ensure**
Always runs the provided body in place with respect to the other chained operations, regardless of whether the chain has failed or succeeded.  The body may be `async` but it may not throw.

```swift
.ensure {
    <body>
}
```

**catch**
* Runs the provided body closure in the event that the chain fails. The error will be passed to the body closure, which may be async and/or throwing.
* If the body closure is throwing, a PartiallyCaughtPromise or a PartiallyCaughtResult will be returned, implying that a further `catch` call is required or the value of the chain must be used in some other way such as through a call to `asyncThrows()`.
* If the body closure does not throw, the result is discardable and returns a `CaughtPromise` or `CaughtResult` type.

```swift
.catch {
    err in
    <body>
    throw OtherError()
}.catch {
    err in 
    <non-throwing body>
}
```

**finally**
`finally` may be run after a chain fully completes. The provided body closure may be async, but not throwing. `finally` will not be available for chains that have not fully caught any failures, or have not used results returned from the last `then` call.  Once finally has been called, no more chained operations with body closures may follow.

```swift
.finally {
    ...
}
```
