import Foundation

/// URLSessionProtocol is a wrapper of the URLSession Apple provides
/// it aims to provide testability to NetworkingKit as it can be mocked, as can be seen in the MockURLProtocol.swift file.
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Extension to ensure that URLSession conforms to the URLSessionProtocol
extension URLSession: URLSessionProtocol {}
