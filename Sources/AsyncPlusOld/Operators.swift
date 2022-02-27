import Foundation

protocol Catchable: ChainNode {
}

extension Catchable {
    
    /// Use `catch` to provide a block that runs when there is an error.
    @discardableResult
    func `catch`(_ body: @escaping (Error) -> ()) -> Catch<T> {
        return chain(Catch<T>(body))
    }
}

/// Mixes in operations available earlier in the chain, before done or catch.
protocol Thenable: Catchable {
}

extension Thenable {
    
    /// Use `map` to provide an async block that maps a value to another (assuming the chain hasn't failed). Equivalent to `then` in PromiseKit and `flatMap` in Rx.
    func map<U>(_ body: @escaping (T) async throws -> U) -> Then<U> {
        return chain(Then<U>({
            (input: Any) -> U in
            return try await body(input as! T)
        }))
    }

    /// Use `done` to run code when the chain has finished running successfully.
    func done(_ body: @escaping (T) -> ()) -> Done {
        return chain(Done({
            (input: Any) -> () in
            body(input as! T)
        }))
    }

    /// Use `recover` to provide a sync or async block that should run as a fallback or plan B in the event of an error.  Recover should return a value that is passed along the chain in this case.
    func recover<U>(_ operation: @escaping (Error) async throws -> U) -> Recover<U> {
        return chain(Recover<U>(operation))
    }

    /// Use `ensure` anywhere along the chain (besides after `finally`) to provide a block that runs regardless of success or error.
    func ensure(_ operation: @escaping () -> ()) -> ThenableEnsure<T> {
        return chain(ThenableEnsure<T>(operation))
    }
}

/// Mixes in operations that take place at the end of the execution chain: catch, ensure, finally
protocol NonThenable: Catchable { }

extension NonThenable {
    
    /// Use `ensure` anywhere along the chain (besides after `finally`) to provide a block that runs regardless of success or error.
    func ensure(_ operation: @escaping () -> ()) -> NonThenableEnsure<T> {
        return chain(NonThenableEnsure<T>(operation))
    }
    
    /// Use `finally` to provide a block at the end of the chain that always runs regardless of success or failure.
    func finally(_ operation: @escaping () -> ()) {
        let _ = chain(Finally(operation))
    }
}

final class Attempt<T>: ChainNode, Thenable {
    
    private var operation: () async throws -> T
    internal var result: Result<T>? = nil
    internal var next: AnyChainNode?

    fileprivate init(_ operation: @escaping () async throws -> T) {
        self.operation = operation
    }

    internal func performOperation(_ result: Result<Any>) async -> Result<T> {
        
        #if DEBUG
        guard case Result<Any>.failure(let error) = result, error as? ErrorIndicator == ErrorIndicator.uninitialized else {
            fatalError("Illegal state: cannot chain the initial attempt node.")
        }
        #endif
        
        do {
            let resultValue: T = try await self.operation()
            return Result<T>.success(resultValue)
        } catch {
            return Result<T>.failure(error)
        }
    }
    
    fileprivate func start() {
        calcResultsForward(inputResult: Result<Any>.failure(ErrorIndicator.uninitialized))
    }
}

func attempt<T>(_ operation: @escaping () async throws -> T) -> Attempt<T> {
    let attempt = Attempt<T>(operation)
    attempt.start()
    return attempt
}

class DoneThenBase<T>: ChainNode {

    private var operation: (Any) async throws -> T
    internal var result: Result<T>? = nil
    internal var next: AnyChainNode?

    internal init(_ operation: @escaping (Any) async throws -> T) {
        self.operation = operation
    }

    internal func performOperation(_ result: Result<Any>) async -> Result<T> {

        switch result {
        case Result<Any>.success(let value):
            do {
                let resultValue: T = try await self.operation(value)
                return Result<T>.success(resultValue)
            }
            catch {
                return Result<T>.failure(error)
            }
        case Result<Any>.failure(let error):
            return Result<T>.failure(error)
        }
    }
}

final class Then<T>: DoneThenBase<T>, Thenable {
}

final class Done: DoneThenBase<()>, NonThenable {

    init(_ operation: @escaping (Any) -> ()) {
        super.init(operation)
    }
}

final class Catch<T>: ChainNode, NonThenable {
    
    private var operation: (Error) -> ()
    internal var result: Result<T>? = nil
    internal var next: AnyChainNode?

    internal init(_ operation: @escaping (Error) -> ()) {
        self.operation = operation
    }

    internal func performOperation(_ result: Result<Any>) async -> Result<T> {

        if case Result<Any>.failure(let error) = result {
            operation(error)
        }
        return result.forceSpecializeAs(type: T.self)
    }
}


final class Recover<T>: ChainNode, Thenable {

    private var operation: (Error) async throws -> T
    internal var result: Result<T>? = nil
    internal var next: AnyChainNode?

    internal init(_ operation: @escaping (Error) async throws -> T) {
        self.operation = operation
    }

    internal func performOperation(_ result: Result<Any>) async -> Result<T> {

        switch result {
        case Result<Any>.success(let value):
            return .success(value as! T)
        case Result<Any>.failure(let error):
            do {
                let resultValue: T = try await self.operation(error)
                return Result<T>.success(resultValue)
            }
            catch {
                // TODO: Reconsider this. Should throw a compound error?
                return Result<T>.failure(error)
            }
        }
    }
}

class EnsureBase<T>: ChainNode {

    fileprivate var operation: () -> ()
    internal var result: Result<T>? = nil
    internal var next: AnyChainNode?

    internal init(_ operation: @escaping () -> ()) {
        self.operation = operation
    }

    internal func performOperation(_ result: Result<Any>) async -> Result<T> {
        operation()
        return result.forceSpecializeAs(type: T.self)
    }
}

final class ThenableEnsure<T>: EnsureBase<T>, Thenable {
}

final class NonThenableEnsure<T>: EnsureBase<T>, NonThenable {
}

final class Finally: EnsureBase<()> {

    override func performOperation(_ result: Result<Any>) async -> Result<T> {
        operation()
        return Result.failure(ErrorIndicator.finallyHasRun)
    }
}
