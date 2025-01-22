import Foundation

/// NetworkingClient aims to provide a simple api for consumers to use to perform network requests
/// It supports only GET requests at the moment but can be improved on later.
public final class NetworkingClient: HTTPClient {
    private let session: URLSessionProtocol

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    /// Get request performs a GET request to a rest API endpoint and expects that the type T is returned from the API
    /// - Parameters:
    ///   - url: This is your url that you want to perform the GET request on
    ///   - parameters:This is a dictionary of your query parameters to be applied to the url
    ///   - headers:This is a dictionary of any headers you wish to pass along in your query
    /// - Returns: The decodable type you specify
    /// - Throws: Throws a [NetworkingError](NetworkingError.swift) which describes what type of issue occured during the request
    public func getRequest<T: Decodable>(url: String, parameters: [String: String]?, headers: [String: String]) async throws -> T {
        guard let urlRequest = createUrl(
            url: url,
            method: .get,
            parameters: parameters,
            headers: headers
        ) else {
            throw NetworkingError.badRequest
        }

        let (data, urlResponse) = try await session.data(for: urlRequest)

        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkingError.parsingError
        }

        debugPrint("Received Response: \(httpUrlResponse)")
        return try handleResponseReceived(data, httpUrlResponse)
    }

    /// This function creates a url from the provided information from the consumer, it appends any query parameters and headers and outputs an optional URLRequest
    func createUrl(url: String, method: HttpMethod, parameters: [String: String]?, headers: [String: String]?) -> URLRequest? {
        guard var url = URL(string: url) else {
            debugPrint("Unable to create url from malformed url: \(url)")
            return nil
        }

        if let parameters {
            let urlQueryItems = parameters.keys.map {
                URLQueryItem(name: $0, value: parameters[$0])
            }
            url = url.appending(queryItems: urlQueryItems)
        }

        var urlRequest = URLRequest(url: url)

        if let headers {
            headers.forEach {
                urlRequest.addValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = method.rawValue

        return urlRequest
    }

    /// This function handles the response received, it trys to decode the response body to the type provide if the status code is 200 or it throws a Networking Error
    func handleResponseReceived<T: Decodable>(
        _ data: Data,
        _ urlResponse: HTTPURLResponse
    ) throws -> T {
        switch urlResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("NetworkingKit: Error decoding response \(error)")
                throw NetworkingError.parsingError
            }
        case 401:
            throw NetworkingError.unauthorized
        case 429:
            throw NetworkingError.rateLimited
        default:
            throw NetworkingError.internalError
        }
    }
}
