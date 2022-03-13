import Foundation
import AsyncPlus

extension Catchable {
    
    func reportToGoogle() {
        self.catchEscaping {
            err in
            print(err)
        }.finallyEscaping {
            print("Done")
        }
    }
}

extension Catchable where T == () {
    func delayThenCatch() {
        // BUG: I don't know why we are not allowed to do this:
        let _ = self.ensure {
            await mockSleep(seconds: 2)
        }
//        .catch {
//            err in
//            print(err)
//        }.finally {
//            print("DONE")
//        }
    }
}

extension Recoverable where T == Int {
    func customRecover() {
        self.recoverEscaping {
            err -> Int in
            print(err)
            throw MockError.notImplemented
            //return 42
        }.then {
            _ in
            await mockSleep(seconds: 2)
        }
    }
}
