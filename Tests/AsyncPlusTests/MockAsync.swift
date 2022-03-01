import Foundation

// Use `sleep` to actually block the thread

func mockSleep(seconds: Int) async {
    try! await mockSleepThrowing(seconds: seconds)
}

func mockSleepThrowing(seconds: Int) async throws {
    try await Task.sleep(nanoseconds: UInt64(seconds) * NSEC_PER_SEC)
}
