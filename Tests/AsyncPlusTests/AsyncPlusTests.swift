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
            // It would be great if we could get this catch statement to trigger a compilation error, but the compiler treats the block above as throwing instead.
            err in
            print("ERROR")
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testChain2() throws {
        
        let expectation1 = expectation(description: "")
        
        // TODO: Make into performance test
        func measure(since: DispatchTime) {
            let now = DispatchTime.now()
            let nanoTime = now.uptimeNanoseconds - since.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            print("Time since start: \(timeInterval) seconds")
        }
        
        var start1: DispatchTime!
        var start2: DispatchTime!
        var start3: DispatchTime!
        
        attempt {
            () -> Int in
            print("Start counting")
            await mockSleep(seconds: 1)
            start1 = DispatchTime.now()
            throw MockError.stackOverflow
        }.recover {
            err -> Int in
            measure(since: start1)
            print("We recovered")
            try! await mockSleepThrowing(seconds: 1)
            start2 = DispatchTime.now()
            throw MockError.noInternet
        }.catch {
            err in
            measure(since: start2)
            print("Error \(err)")
            try await mockSleepThrowing(seconds: 1)
            print("Throwing notImplemented")
            start3 = DispatchTime.now()
            throw MockError.notImplemented
        }.catch {
            err in
            measure(since: start3)
            print("Catch run")
            XCTAssert(err as! MockError == MockError.notImplemented)
            print("Type asserted")
            try! await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDeferredChaining() throws {
        
        let expectation1 = expectation(description: "")
        let expectation2 = expectation(description: "")
        
        let firstBit = attempt {
            () -> Int in
            try await mockSleepThrowing(seconds: 1)
            return 2
        }.then {
            v -> () in
            print("We did 0.5 seconds of async work.")
        }.then {
            v -> String in
            XCTAssert(v == 2)
            await mockSleep(seconds: 1)
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
            await mockSleep(seconds: 1)
            expectation2.fulfill()
        }
        
        // Calls to `sleep` apparently pause the waitForExpectations timeout as well..
        waitForExpectations(timeout: 3.1, handler: nil)
    }
    
    func testWithSleep(sleepTime: UInt32) throws {
        let expectation = expectation(description: "will run catch block")

        let task = attempt {
            print("TASK")
            throw MockError.pandemic
        }

        sleep(sleepTime)

        task.catch {
            error in
            print("CATCH")
            print(error)
            expectation.fulfill()
        }
        print("GOT TO CODE BELOW TASK")

        waitForExpectations(timeout: 2, handler: nil)
    }

    // These are the difference between chaining beind done before execution, or execution being done before chaining
    func testNoSleep() throws {
        try testWithSleep(sleepTime: 0)
    }

    func testWithSleep() throws {
        try testWithSleep(sleepTime: 2)
    }

    func testChain3() throws {

        let expectation1 = expectation(description: "will run done block")
        let expectation2 = expectation(description: "will run finally block")

        attempt { () -> Int in
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            return 32
        }.then {
            (num: Int) -> Int in
            print("Should be 32:")
            print(num)
            XCTAssertEqual(num, 32)
            return 5
        }.then {
            print("Should be 5:")
            print($0)
            XCTAssertEqual($0, 5)
            expectation1.fulfill()
        }.catch {
            err in
            print("Caught: \(err)")
        }.finally {
            print("Finally")
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }


    func testChain4() throws {

        let expectation1 = expectation(description: "will run catch block")
        let expectation2 = expectation(description: "will run ensure block")
        let expectation3 = expectation(description: "will run finally block")

        attempt { () -> Int in
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            return 32
        }.then {
            (num: Int) -> Int in
            print("Should be 32:")
            print(num)
            return 5
        }.then {
            print("Should be 5:")
            print($0)
            expectation1.fulfill()
        }.catch {
            err in
            print("Caught: \(err)")
        }.ensure {
            print("Ensure")
            expectation2.fulfill()
        }.finally {
            print("Finally")
            expectation3.fulfill()
        }

        waitForExpectations(timeout: 4, handler: nil)
    }
}
