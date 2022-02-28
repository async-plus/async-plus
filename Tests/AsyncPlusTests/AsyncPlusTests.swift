import XCTest
@testable import AsyncPlus

final class AsyncPlusTests: XCTestCase {
    
    func testInstant1() throws {
        
        let expectation = expectation(description: "")
        
        attempt {
            () -> Int in
            print("Start counting")
            try await mockSleepThrowing(seconds: 1)
            throw MockError.stackOverflow
        }.recover {
            err in
            await mockSleep(seconds: 1)
            print("We recovered")
            expectation.fulfill()
            return 2
        }.catch {
            err in
            try! await mockSleepThrowing(seconds: 1)
            print("Error \(err)")
        }
        
        waitForExpectations(timeout: 2.1, handler: nil)
    }
    
    func testInstant2() throws {
        
        let expectation = expectation(description: "")
        
        attempt {
            () -> Int in
            print("Start counting")
            await mockSleep(seconds: 1)
            throw MockError.stackOverflow
        }.recover {
            err -> Int in
            print("We recovered")
            try! await mockSleepThrowing(seconds: 1)
            throw MockError.noInternet
        }.catch {
            err in
            print("Error \(err)")
            try await mockSleepThrowing(seconds: 1)
            throw MockError.notImplemented
        }.catch {
            err in
            XCTAssert(err as! MockError == MockError.notImplemented)
            try! await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 4.1, handler: nil)
    }
}
