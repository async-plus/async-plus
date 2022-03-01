# FAQ

***Why am I getting an unused value error?***

Uncaught errors will raise an "unused result" warning at compile time. Similarly, unused results returned from `then` or `recover` will raise a warning.

***What is the difference between the `ensure` operation and using Swift's built-in `defer`?***

Swift's `defer` will execute the provided block at the end of the current scope. This is different from `ensure`, which executes regardless of success or failure at the place that it is put in the chain. Although `defer` preserves order of execution with regard to other `defer` statements, this order is not in relation to the surrounding `await` operations like `ensure` is. Additionally, if a function throws before `defer` is called, then the block will not be run at all. 

