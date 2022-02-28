import XCTest
@testable import AsyncPlus

struct Promise<T>: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = T
    var hasGivenValue: Bool = false
    let body: () async throws -> T
    
    init(body: @escaping () async throws -> T) {
        self.body = body
    }
    
    mutating func next() async throws -> Element? {
        
        defer { hasGivenValue = true }
        if hasGivenValue {
            return nil
        }
        
        return try await body()
    }

    func makeAsyncIterator() -> Promise<T> {
        self
    }
}

final class AsyncPlusTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testChaining() throws {
        
        
        attempt {
            print("Start counting")
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            throw ErrorIndicator.finallyHasRun
        }.recover {
            err in
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            // End counting
        }.catch {
            err in
            throw ErrorIndicator.finallyHasRun
        }
    }

}
