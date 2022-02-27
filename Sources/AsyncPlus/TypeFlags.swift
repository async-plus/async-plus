import Foundation

/// Indicates whether failure is an option
class ThrowsFlag {
    
}

final class Never: ThrowsFlag {
    
}

final class Sometimes: ThrowsFlag {
    
}


/// Indicates whether results are async or instantaneous
class WhenFlag {
    
}

final class Instant: WhenFlag {
    
}

final class Async: WhenFlag {
    
}

