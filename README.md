<a href="https://discord.gg/vaAhGvvHpW">![async+](Documentation/images/github-heading.png)</a>

<p align="center">
  <a href="https://github.com/async-plus/async-plus/blob/main/Documentation/index.md"><img src="https://img.shields.io/badge/read%20the-docs-blue" alt="Documentation"></a>
  <a href="https://discord.gg/vaAhGvvHpW"><img src="https://img.shields.io/discord/946863161460547684.svg" alt="Team Chat"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License"></a>
  <a href="https://github.com/async-plus/async-plus/actions"><img src="https://github.com/async-plus/async-plus/workflows/test/badge.svg" alt="Continuous Integration"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/swift-5.5-brightgreen.svg" alt="Swift 5.5"></a>
  <a href="https://twitter.com/async_plus"><img src="https://img.shields.io/badge/twitter-async__plus-5AA9E7.svg" alt="Twitter"></a>
</p>
<br>

Async+ for Swift provides a simple **chainable interface** for your async and throwing code, similar to promises and futures.  Have the best of both worlds: you can use the async solution built into the language, but keep all the useful features of promises.

### ✏️  Usage

Basic chaining operations are:

* `.then` arranges blocks one after another, passing along any values

* `.recover` recovers from a thrown error with a backup value (or block to run)
* `.catch` catches any errors (and allows you to throw new ones for later catch blocks)
* `attempt { ... }` kicks off a chain as in the example below:

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

Async+ allows async and/or throwing code to remain unnested, modular, and concise.  For a full list of operations see the [documentation](Documentation/index.md).

Want to still use chained code within a `do`/`catch` block, `Task.init`, or similar context? Easy: chains are fully interoperable with async and/or throwing contexts via the operations `.async()`, and `.asyncThrows()` at the end of the chain, for example:

```
let foo = await attempt{ ... }.then{ ... }.async() // non-throwing chain
let foo = try await attempt{ ... }.then{ ... }.asyncThrows() // throwing chain
```
If the chain doesn't throw you will not be able to call `asyncThrows` on it (it is a `Guarantee<T>` type rather than a `Promise<T>` type), and vice versa.  Similarly, chains with potential for uncaught errors will raise an unused value warning at compilation time.

### 💾  Installation

Install the Async+ **SwiftPM** package in Xcode by going to `<your project> -> <ProjectName> -> Package Dependencies -> "+"` and entering: `https://github.com/async-plus/async-plus.git`

Or modify your `Package.swift` file:

```swift
dependencies: [
    .Package(url: "https://github.com/async-plus/async-plus.git", majorVersion: 0, minor: 1),
] 
```

To use Async+ in a Swift file you must add `import AsyncPlus` to the top of the file.

###  📘  Documentation

[Index](Documentation/index.md)

[Getting Started](Documentation/getting-started.md)

[Operations](Documentation/operations.md)

[Using chains from async or throwing contexts](Documentation/async-or-throwing-contexts.md)

[Motivation and common patterns](Documentation/motivation-and-common-patterns.md)

[Cancellation](Documentation/cancellation.md)

[Migrating from PromiseKit](Documentation/migrating-from-promisekit.md)

[Frequently asked questions (FAQ)](Documentation/faq.md)

### 🚀  Feedback and Contributing

This package is in its initial release: please provide feedback and suggestions in order to help shape the API, either by submitting an [issue](https://github.com/async-plus/async-plus/issues/new) on Github or sending a message on [Discord](https://discord.gg/vaAhGvvHpW). 

