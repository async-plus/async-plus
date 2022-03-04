@testable import AsyncPlus

func test() {
    let r: PartiallyCaughtPromise<Int> = attempt {
        () -> Int in
        try await mockSleepThrowing(seconds: 1)
        return 2
    }.catch {
        err in
        print(err)
        throw MockError.stackOverflow
    }
}
