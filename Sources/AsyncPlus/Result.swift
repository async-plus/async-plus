import Foundation

public typealias SimpleResult<Success> = Result<Success, Error>

internal extension Result {
    func optional() -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
}
