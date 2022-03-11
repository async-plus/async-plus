import Foundation

@testable import AsyncPlus





func test() {
    attempt {
        () -> Int in
        try await mockSleepThrowing(seconds: 1)
        return 2
    }.catch {
        err in
        print(err)
        throw MockError.stackOverflow
    }
}
