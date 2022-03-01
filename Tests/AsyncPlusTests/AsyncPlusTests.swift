import XCTest
@testable import AsyncPlus

final class AsyncPlusTests: XCTestCase {
    
    func testChain1() throws {
        
        let expectation1 = expectation(description: "")
        
        attempt {
            () -> Int in
            print("Start counting")
            try await mockSleepThrowing(seconds: 1)
            throw MockError.stackOverflow
        }.recover {
            err in
            await mockSleep(seconds: 1)
            print("We recovered")
            expectation1.fulfill()
            return 2
        }.catch {
            err in
            try! await mockSleepThrowing(seconds: 1)
            print("Error \(err)")
        }
        
        waitForExpectations(timeout: 2.1, handler: nil)
    }
    
    func testChain2() throws {
        
        let expectation1 = expectation(description: "")
        
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
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 4.1, handler: nil)
    }
    
    func testDeferredChaining() throws {
        
        let expectation1 = expectation(description: "")
        let expectation2 = expectation(description: "")
        
        let firstBit = attempt {
            () -> Int in
            try await mockSleepThrowing(seconds: 0.5)
            return 2
        }.then {
            v -> () in
            print("We did 0.5 seconds of async work.")
        }.then {
            v -> String in
            XCTAssert(v == 2)
            await mockSleep(seconds: 0.25)
            return "Bob"
        }
        
        sleep(2)
        
        print("Let's resume our chaining..")
        
        // When we call this `then`, firstBit will already have resolved to a result
        firstBit.then {
            str in
            XCTAssert(str == "Bob")
            expectation1.fulfill()
        }.catch {
            err in
            print("This won't get here")
        }.finally {
            await mockSleep(seconds: 0.2)
            expectation2.fulfill()
        }
        
        // Calls to `sleep` apparently pause the waitForExpectations timeout as well..
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
