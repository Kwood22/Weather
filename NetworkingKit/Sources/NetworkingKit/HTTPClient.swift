/// HTTPClient aims to provide a simple api for consumers to use to perform network requests
/// It supports only GET requests at the moment but can be improved on later.
public protocol HTTPClient {
    /// Get request performs a GET request to a rest API endpoint and expects that the type T is returned from the API
    /// - Parameters:
    ///   - url: This is your url that you want to perform the GET request on
    ///   - parameters:This is a dictionary of your query parameters to be applied to the url
    ///   - headers:This is a dictionary of any headers you wish to pass along in your query
    /// - Returns: The decodable type you specify
    /// - Throws: Throws a [NetworkingError](NetworkingError.swift) which describes what type of issue occured during the request
    func getRequest<T: Decodable>(url: String, parameters: [String: String]?, headers: [String: String]) async throws -> T
}

public extension HTTPClient {
    func getRequest<T: Decodable>(url: String, parameters: [String: String]? = nil, headers: [String: String] = [:]) async throws -> T {
        try await getRequest(url: url, parameters: parameters, headers: headers)
    }
}
