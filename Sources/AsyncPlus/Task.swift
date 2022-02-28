import Foundation

typealias NonFailableTask<T> = Task<T, Never>
typealias FailableTask<T> = Task<T, Error>

