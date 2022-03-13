import Foundation

enum MappingType: CaseIterable {
    case normal
    case optional
    case regex
    case optionalRegex
    
    var symbol: String {
        switch self {
        case .normal:
            return "=>"
        case .optional:
            return "?=>"
        case .regex:
            return "R=>"
        case .optionalRegex:
            return "R?=>"
        }
    }
    
    var isOptional: Bool {
        switch self {
        case .optional, .optionalRegex:
            return true
        case .normal, .regex:
            return false
        }
    }
    
    var isRegex: Bool {
        switch self {
        case .regex, .optionalRegex:
            return true
        case .normal, .optional:
            return false
        }
    }
}
