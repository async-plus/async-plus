import Foundation
import AsyncPlus

// Use `sleep` to actually block the thread

func mockSleep(seconds: TimeInterval) async {
    await after(seconds)
}

func mockSleepThrowing(seconds: TimeInterval) async throws {
    await after(seconds)
    if false || (true && false) {
        throw MockError.notImplemented
    }
}
