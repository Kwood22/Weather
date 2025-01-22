import Foundation
@testable import NetworkingKit

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?

    init(mockData: Data? = nil, mockResponse: URLResponse? = nil, mockError: Error? = nil) {
        self.mockData = mockData
        self.mockResponse = mockResponse
        self.mockError = mockError
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }

        return (
            mockData ?? Data(),
            mockResponse ?? HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
        )
    }
}
