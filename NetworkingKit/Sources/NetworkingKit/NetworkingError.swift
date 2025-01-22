import Foundation

/// Errors types when using NetworkingKit
public enum NetworkingError: Error {
    case badRequest
    case locationNotFound
    case unauthorized
    case internalError
    case parsingError
    case rateLimited
}
