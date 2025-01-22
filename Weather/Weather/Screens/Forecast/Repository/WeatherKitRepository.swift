import CoreLocation
import NetworkingKit

/// Repository to be used to gather the weather Forecast for a specific location.
protocol WeatherRepository {
    /// Function to fetch the weather Forecast
    /// - Parameters:
    ///   - location: The location to get the Forecast for of type CLLocation
    ///   - units: The units that the Forecast should be given in, either metric or imperial
    /// - Returns: OpenWeatherResponse, giving the current weather conditions
    /// - Throws: Throws NetworkingError types depending on the type of error that occured.
    func fetchCurrentWeather(for location: CLLocation) async throws -> OpenWeatherResponse
}

final class WeatherRepositoryImplementation: WeatherRepository {
    private let networkingClient: HTTPClient

    init(networkingClient: HTTPClient = NetworkingClient()) {
        self.networkingClient = networkingClient
    }

    func fetchCurrentWeather(for location: CLLocation) async throws -> OpenWeatherResponse {
        let queryParameters = [
            "lat": "\(location.coordinate.latitude)",
            "lon": "\(location.coordinate.longitude)",
            "appid": Config.apiKey,
            "units": "metric",
            "exclude": "minutely,alerts",
        ]

        return try await networkingClient.getRequest(
            url: Config.baseAPIUrl,
            parameters: queryParameters
        )
    }
}
