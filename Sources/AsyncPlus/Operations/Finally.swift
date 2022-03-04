//import Foundation
//
//extension AnyStageValue {
//    
//    @discardableResult
//    public func finally(_ body: () -> ()) -> FinalizedValue<T> {
//        body()
//        return FinalizedValue<T>(value)
//    }
//    
//    @discardableResult
//    public func finally(_ body: @escaping () async -> ()) -> FinalizedGuarantee<T> {
//        return FinalizedGuarantee<T>(Task.init {
//            await body()
//            return value
//        })
//    }
//}
//
//extension AnyStageResult where Stage == CompletelyCaught {
//    
//    @discardableResult
//    public func finally(_ body: () -> ()) -> FinalizedResult<T> {
//        body()
//        return FinalizedResult(result)
//    }
//    
//    @discardableResult
//    public func finally(_ body: @escaping () async -> ()) -> FinalizedPromise<T> {
//        return FinalizedPromise<T>(Task.init {
//            await body()
//            return try result.get()
//        })
//    }
//}
//
//extension Guarantee {
//    
//    @discardableResult
//    public func finally(_ body: @escaping () -> ()) -> FinalizedGuarantee<T> {
//        return FinalizedGuarantee(Task.init {
//            let value = await task.value
//            body()
//            return value
//        })
//    }
//    
//    @discardableResult
//    public func finally(_ body: @escaping () async -> ()) -> FinalizedGuarantee<T> {
//        return FinalizedGuarantee(Task.init {
//            let value = await task.value
//            await body()
//            return value
//        })
//    }
//}
//
//extension AnyStagePromise where Stage == CompletelyCaught {
//    
//    @discardableResult
//    public func finally(_ body: @escaping () -> ()) -> FinalizedPromise<T> {
//        return FinalizedPromise(Task.init {
//            let result = await task.result
//            body()
//            return try result.get()
//        })
//    }
//    
//    @discardableResult
//    public func finally(_ body: @escaping () async -> ()) -> FinalizedPromise<T> {
//        return FinalizedPromise(Task.init {
//            let result = await task.result
//            await body()
//            return try result.get()
//        })
//    }
//}
