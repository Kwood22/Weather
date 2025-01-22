import Foundation
@testable import NetworkingKit
import Testing

@Suite("Test Networking Client")
struct NetworkingClientTests {
    let networkingclient = NetworkingClient()

    // MARK: - Tests for getRequest function

    @Test("Error: Test invalid url returns error")
    func testGetRequestWithInvalidUrl() async {
        await #expect(throws: NetworkingError.badRequest) {
            let _: MockDecodable = try await networkingclient.getRequest(url: "", parameters: nil, headers: [:])
        }
    }

    @Test("Error: Test session.data throws an error")
    func testGetRequestSessionThrowingError() async {
        let mockSession = MockURLSession(mockError: NetworkingError.internalError)
        let client = NetworkingClient(session: mockSession)

        await #expect(throws: NetworkingError.internalError) {
            let _: MockDecodable = try await client.getRequest(url: "https://example.com", parameters: nil, headers: [:])
        }
    }

    @Test("Error: Test session.data returns invalid urlResponse")
    func testGetRequestInvalidUrlResponse() async {
        let mockSession = MockURLSession(mockResponse: URLResponse(url: URL(string: "https://example.com")!, mimeType: nil, expectedContentLength: 500, textEncodingName: nil))
        let client = NetworkingClient(session: mockSession)

        await #expect(throws: NetworkingError.parsingError) {
            let _: MockDecodable = try await client.getRequest(url: "https://example.com", parameters: nil, headers: [:])
        }
    }

    @Test("Error: Test invalid response body")
    func testGetRequestInvalidResponseBody() async {
        let mockSession = MockURLSession(
            mockData: createMockedData(type: MockDecodableB(name: "Test")),
            mockResponse: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        let client = NetworkingClient(session: mockSession)

        await #expect(throws: NetworkingError.parsingError) {
            let _: MockDecodable = try await client.getRequest(url: "https://example.com", parameters: nil, headers: [:])
        }
    }

    @Test("Success: Test correct response body")
    func testGetRequestValidResponseBody() async {
        let mockSession = MockURLSession(
            mockData: createMockedData(type: MockDecodable(id: "123")),
            mockResponse: HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        )
        let client = NetworkingClient(session: mockSession)

        let response: MockDecodable = try! await client.getRequest(url: "https://example.com", parameters: nil, headers: [:])
        #expect(response.id == "123")
    }

    // MARK: - Tests for createUrl function

    @Test("Error: Test invalid url")
    func testInvalidUrl() async throws {
        let urlRequest = networkingclient.createUrl(url: "", method: .get, parameters: nil, headers: nil)
        #expect(urlRequest == nil)
    }

    @Test("Success: Test url request creation with no query parameters")
    func testSuccessfullUrlRequestCreationWithNoQueryParameters() async throws {
        let urlRequest = networkingclient.createUrl(url: "https://example.com", method: .get, parameters: nil, headers: nil)
        let queryPath = urlRequest?.url?.query()
        #expect(urlRequest != nil)
        #expect(queryPath == nil)
    }

    @Test("Success: Test url request creation with query parameters")
    func testSuccessfullUrlRequestCreationWithQueryParameters() async throws {
        let queryParameters = [
            "Content-Type": "application/json",
            "TestHeader1": "TestValue1"
        ]

        let expectedQueryPaths = ["TestHeader1=TestValue1&Content-Type=application/json", "Content-Type=application/json&TestHeader1=TestValue1"]

        let urlRequest = networkingclient.createUrl(url: "https://example.com", method: .get, parameters: queryParameters, headers: nil)
        let queryPath = urlRequest?.url?.query()
        #expect(urlRequest != nil)
        #expect(expectedQueryPaths.contains(where: { $0 == queryPath }))
    }

    @Test("Success: Test url request creation with no headers")
    func testSuccessfullUrlRequestCreationWithNoHeaders() async throws {
        let urlRequest = networkingclient.createUrl(url: "https://example.com", method: .get, parameters: nil, headers: nil)
        #expect(urlRequest != nil)
        #expect(urlRequest?.allHTTPHeaderFields == ["Accept": "application/json"])
    }

    @Test("Success: Test url request creation with headers")
    func testSuccessfullUrlRequestCreationWithHeaders() async throws {
        let headers = [
            "Content-Type": "application/json",
            "TestHeader1": "TestValue1"
        ]

        let urlRequest = networkingclient.createUrl(url: "https://example.com", method: .get, parameters: nil, headers: headers)
        #expect(urlRequest != nil)
        #expect(urlRequest?.value(forHTTPHeaderField: "Content-Type") == headers["Content-Type"])
        #expect(urlRequest?.value(forHTTPHeaderField: "TestHeader1") == headers["TestHeader1"])
    }

    // MARK: - Tests for handleResponseReceived function

    @Test("Success: Test handling of response with correct decodable type")
    func testHandleingOfResponseCorrectDecodableType() async throws {
        let responseDecodable: MockDecodable = try networkingclient.handleResponseReceived(
            createMockedData(type: MockDecodable(id: "123")),
            creatMockedHttpResponse(code: 200)
        )
        #expect(responseDecodable.id == "123")
    }

    @Test("Error: Test handling of response with incorrect type")
    func testHandleingOfResponseIncorrectDecodableType() async throws {
        #expect(throws: NetworkingError.parsingError) {
            let _: MockDecodable = try networkingclient.handleResponseReceived(
                createMockedData(type: MockDecodableB(name: "B")),
                creatMockedHttpResponse(code: 200)
            )
        }
    }

    @Test("Error: Test handling of response with status code 401")
    func testHandleingOfResponseStatus401() async throws {
        #expect(throws: NetworkingError.unauthorized) {
            let _: MockDecodable = try networkingclient.handleResponseReceived(
                createMockedData(type: MockDecodable(id: "123")),
                creatMockedHttpResponse(code: 401)
            )
        }
    }

    @Test("Error: Test handling of response with status code 429")
    func testHandleingOfResponseStatus429() async throws {
        #expect(throws: NetworkingError.rateLimited) {
            let _: MockDecodable = try networkingclient.handleResponseReceived(
                createMockedData(type: MockDecodable(id: "123")),
                creatMockedHttpResponse(code: 429)
            )
        }
    }

    @Test("Error: Test handling of response with some other status code")
    func testHandleingOfResponseSomeOtherStatusCode() async throws {
        #expect(throws: NetworkingError.internalError) {
            let _: MockDecodable = try networkingclient.handleResponseReceived(
                createMockedData(type: MockDecodable(id: "123")),
                creatMockedHttpResponse(code: 500)
            )
        }
    }

    // MARK: - Mocking Helper functions

    private func createMockedData(type: some Encodable) -> Data {
        try! JSONEncoder().encode(type)
    }

    private func creatMockedHttpResponse(code: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}

struct MockDecodable: Codable {
    let id: String
}

struct MockDecodableB: Codable {
    let name: String
}
