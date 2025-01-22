import CoreLocation
import NetworkingKit
import Testing
@testable import Weather

struct MockWeatherRepository: WeatherRepository {
    var error: Error?
    let mockResponse = OpenWeatherResponse(
        current: Current(dt: Date.now, temp: 10.99, weather: [WeatherInfo(description: "Cold and rainy", main: "Rain", icon: "icon")]),
        hourly: [
            Hourly(dt: Date.now, temp: 10.99, weather: [WeatherInfo(description: "Cold and rainy", main: "Rain", icon: "icon")])
        ],
        daily: [
            Daily(dt: Date.now, temp: Temperature(min: 9, max: 20), weather: [WeatherInfo(description: "Cold and rainy", main: "Rain", icon: "icon")])
        ]
    )

    enum ErrorType {
        case network
        case other
    }

    enum OtherError: Error {
        case someOtherError
    }

    init(
        errorType: ErrorType? = nil
    ) {
        if let errorType {
            switch errorType {
            case .network: error = NetworkingError.badRequest
            case .other: error = OtherError.someOtherError
            }
        }
    }

    func fetchCurrentWeather(for location: CLLocation) async throws -> OpenWeatherResponse {
        if let error {
            throw error
        }

        return mockResponse
    }
}
