import Foundation

// Use `sleep` to actually block the thread

func mockSleep(seconds: TimeInterval) async {
    try! await mockSleepThrowing(seconds: seconds)
}

func mockSleepThrowing(seconds: TimeInterval) async throws {
    try await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
}
