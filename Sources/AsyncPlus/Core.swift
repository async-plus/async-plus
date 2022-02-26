import Foundation

let backgroundSyncQueue = DispatchQueue(label: "serial-queue")

/// A type-erased chain node representing an operation such as catch, recover, ensure etc.
protocol AnyChainNode: AnyObject {
    
    /// The next chain node in the linked list
    var next: AnyChainNode? { get set }
    
    /// Calculates and stores chain node results starting with the current chain node and continuing forward through the linked list
    func calcResultsForwardAsync(inputResult: Result<Any>) async
}

/// The type-constrained chain node PAT
protocol ChainNode: AnyChainNode {
    
    associatedtype T

    /// The stored result
    var result: Result<T>? { get set }

    /// The result-to-result mapping operation that the chain node represents
    func performOperation(_ result: Result<Any>) async -> Result<T>
}

extension ChainNode {

    internal func calcResultsForwardAsync(inputResult: Result<Any>) async {
        
        // Safely stores the result of the operation (thread safety is key here)
        let result: Result<T> = await self.performOperation(inputResult)
        let shouldRunNext: Bool = backgroundSyncQueue.sync {
            // We need these two lines to be atomic: otherwise imagine what happens if a .then is added right in between them: it would see result and try to run the chain double.
            self.result = result
            return next != nil
        }
        
        // Run the chain forward
        if shouldRunNext {
            await next!.calcResultsForwardAsync(inputResult: self.result!.asAny())
        }
    }
    
    /// Wraps calcResultsForwardAsync in Task.init
    internal func calcResultsForward(inputResult: Result<Any>) {
        // TODO: Store this for cancellation
        Task.init {
            await calcResultsForwardAsync(inputResult: inputResult)
        }
    }
    
    /// Chains another operation in the linked list, executing it at call-time if possible.
    internal func chain<Next: ChainNode>(_ node: Next) -> Next {
        // We must make appending of next and getting result atomic.
        let hasResult: Bool = backgroundSyncQueue.sync {
            self.next = node
            return self.result != nil
        }
        if hasResult {
            let result: Result<T> = self.result!
            node.calcResultsForward(inputResult: result.asAny())
        } else {
            // Results are not instantaneous in this case
        }
        return node
    }
}

