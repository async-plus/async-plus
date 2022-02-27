import Foundation

let backgroundSyncQueue = DispatchQueue(label: "serial-queue")

func attempt<T>(_ body: () -> T) {
    
}

func attempt<T>(_ body: () throws -> T) {
    
}

func attempt<T>(_ body: () async -> T) {
    
}

func attempt<T>(_ body: () async throws -> T) {
    
}
