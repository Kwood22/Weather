import NetworkingKit

class MockNetworkingKitClient: HTTPClient {
    var mockResponse: (any Codable)?
    var mockError: Error?

    init(mockResponse: (any Codable)? = nil, mockError: Error? = nil) {
        self.mockResponse = mockResponse
        self.mockError = mockError
    }

    func getRequest<T: Decodable>(url: String, parameters: [String: String]?, headers: [String: String]) async throws -> T {
        if let mockError {
            throw mockError
        }
        return mockResponse as! T
    }
}
