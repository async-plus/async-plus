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
    
    func testInstant1() throws {
        
        let expectation = expectation(description: "")
        
        attempt {
            () -> Int in
            print("Start counting")
            throw ErrorIndicator.finallyHasRun
        }.recover {
            err in
            print("We recovered")
            expectation.fulfill()
            return 2
        }.catch {
            err in
            print("Error \(err)")
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInstant2() throws {
        
        let expectation = expectation(description: "")
        
        attempt {
            () -> Int in
            print("Start counting")
            throw ErrorIndicator.finallyHasRun
        }.recover {
            err -> Int in
            print("We recovered")
            throw ErrorIndicator.uninitialized
        }.catch {
            err in
            print("Error \(err)")
            throw ErrorIndicator.hasBeenCaught
        }.catch {
            err in
            XCTAssert(err as! ErrorIndicator == ErrorIndicator.hasBeenCaught)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}
