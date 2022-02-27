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
        
//        let two: Int = attempt {
//            print("Hello world")
//            throw ErrorIndicator.finallyHasRun
//        }.recover {
//            err in
//            return 2
//        }
    }
    
    func testFlatMap() throws {
        
        let expectation = expectation(description: "Wait for 5 seconds")
        
        Task.init {
            let promise = Promise<Int> {
                print("Starting task one")
                try! await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                print("I have slept for 2 seconds")
                return 2
            }.flatMap {
                _ in
                return Promise<Int> {
                    print("Starting task two")
                    try! await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
                    print("I have slept for 5 seconds total")
                    
                    return 3
                }
            }
            
            
            for try await i in promise {
                print("got value \(i)")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 16, handler: nil)
        
    }
}
