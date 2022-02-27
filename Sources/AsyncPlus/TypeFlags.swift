import Foundation


/// Indicates whether results are async or instantaneous
class TemporalFlagBase {
    
}

final class Instant: TemporalFlagBase {
    
}

final class Async: TemporalFlagBase {
    
}

/// Indicates whether failure is an option
class FailureFlagBase {
    
}

final class Never: FailureFlagBase {
    
}

final class Sometimes: FailureFlagBase {
    
}
