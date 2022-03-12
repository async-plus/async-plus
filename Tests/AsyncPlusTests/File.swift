import Foundation

@testable import AsyncPlus

func test() {
    attempt {
        try await mockSleepThrowing(seconds: 1)
    }.catch {
        err in
        print(err)
        throw MockError.stackOverflow
    }.catchEscaping {
        err in
        print(err)
    }
}
