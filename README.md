<a href="https://discord.gg/vaAhGvvHpW">![async+](Images/heading.png)</a>

<p align="center">
  <a href="https://docs.asyncplus.codes"><img src="https://img.shields.io/badge/read%20the-docs-blue" alt="Documentation"></a>
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

Async+ allows async and/or throwing code to remain unnested, modular, and concise.  For a full list of operations see the [documentation](https://docs.asyncplus.codes).

Want to still use chained code within a `do`/`catch` block, `Task.init`, or similar context? Easy: chains are fully interoperable with async and/or throwing contexts via the operations `.async()`, and `.asyncThrows()` at the end of the chain, for example:

```
let foo = await attempt{ ... }.then{ ... }.async() // non-throwing chain
let foo = try await attempt{ ... }.then{ ... }.asyncThrows() // throwing chain
```
If the chain doesn't throw you will not be able to call `asyncThrows` on it (it is a `Guarantee<T>` type rather than a `Promise<T>` type), and vice versa.  Similarly, chains with potential for uncaught errors will raise an unused value warning at compilation time.

### 💾  Installation

Async+ can be installed with either SwiftPM or CocoaPods.

For **SwiftPM**, in Xcode go to `<your project> -> <ProjectName> -> Package Dependencies -> "+"` and enter: `https://github.com/async-plus/async-plus.git`

Or modify your `Package.swift` file:

```swift
dependencies: [
    .Package(url: "https://github.com/async-plus/async-plus.git", majorVersion: 1, minor: 1),
] 
```

For **CocoaPods**, in your [Podfile](https://guides.cocoapods.org/syntax/podfile.html):

```
target "Change Me!" do
  pod "AsyncPlus", "~> 1.1"
end
```

To use Async+ in a Swift file you must `import AsyncPlus` at the top of the file.

###  📘  Documentation

[Getting Started](https://docs.asyncplus.codes/getting-started/)

[Operations](https://docs.asyncplus.codes/operations/)

[Using chains from async or throwing contexts](https://docs.asyncplus.codes/async-or-throwing-contexts/)

[Motivation and common patterns](https://docs.asyncplus.codes/motivation-and-common-patterns/)

[Cancellation](https://docs.asyncplus.codes/cancellation/)

[Migrating from PromiseKit](https://docs.asyncplus.codes/migrating-from-promisekit/)

[Frequently asked questions (FAQ)](https://docs.asyncplus.codes/faq/)

### 🚀  Feedback and Contributing

This package is in its initial release: please provide feedback and suggestions in order to help shape the API, either by submitting an [issue](https://github.com/async-plus/async-plus/issues/new) on Github or sending a message on [Discord](https://discord.gg/vaAhGvvHpW).

Special thanks to the developers of PromiseKit and [mxcl](https://github.com/mxcl) for inspiring this work and promoting its development.

