import Foundation

public typealias NonFailableTask<T> = Task<T, Never>
public typealias FailableTask<T> = Task<T, Error>

