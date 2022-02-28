import Foundation

/// We can use errors to communicate internally
internal enum ErrorIndicator: Error {
    case uninitialized
    case hasBeenCaught
    case finallyHasRun
}
