# Getting Started

### 💾  Installation

Async+ must be installed using SwiftPM at the moment.

**With Xcode (SwiftPM)** 

Install the Async+ package in Xcode by going to `<your project> -> <ProjectName> -> Package Dependencies -> "+"` and entering: `https://github.com/async-plus/async-plus.git` in the search bar in the top right corner of the window.

**With Package.swift**

If you are developing a Swift package or a Linux-based Swift application you will have a `Package.swift` file. Modify it to match the pattern below, updating the major and minor version numbers to the latest version of Async+ (which you can find [here](https://github.com/async-plus/async-plus/tags)):

```swift
dependencies: [
    .Package(url: "https://github.com/async-plus/async-plus.git", majorVersion: 0, minor: 1),
] 
```

The above example uses version 0.1.

**Importing Async+**

To use Async+ you must import it with `import AsyncPlus` .

### ✏️  Basic Usage

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

To play around with the API you may find it useful to use the convenience `after` function, which waits a provided number of seconds:

```swift
attempt {
    after(2.0)
    return "Hello "
}.then {
    hello in 
    print(hello + "World")
}
```



