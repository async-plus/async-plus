import Foundation

/// Indicates whether failure is an option
class FailsFlagBase {
    
}

final class Never: FailsFlagBase {
    
}

final class Sometimes: FailsFlagBase {
    
}


/// Indicates whether results are async or instantaneous
class WhenFlagBase {
    
}

final class Instant: WhenFlagBase {
    
}

final class Async: WhenFlagBase {
    
}

