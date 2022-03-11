import Foundation
import AsyncPlus

extension Catchable {
    
    func reportToGoogle() {
        self.catch {
            err in
            print(err)
        }.ensure {
            print("Reported to Google")
        }
    }
}

extension Ensurable {
    func delayThenCatch() {
        self.ensure {
            await mockSleep(seconds: 2)
        }.catch {
            err in
            print(err)
        }
    }
    
}
