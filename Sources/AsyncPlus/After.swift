import Foundation

public func after(_ timeInterval: TimeInterval) async {
    await withCheckedContinuation { continuation in
        // We use DispatchQueue as Task.sleep is not reliable
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            continuation.resume()
        }
    }
}














