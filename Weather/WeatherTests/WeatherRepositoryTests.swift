import CoreLocation
import NetworkingKit
import Testing
@testable import Weather

@Suite("Weather Repository Tests")
struct WeatherRepositoryTests {
    @Test("Test fetching weather")
    func testFetchingWeather() async throws {
        let weatherResponse = try await WeatherRepositoryImplementation(
            networkingClient: MockNetworkingKitClient(mockResponse: mockResponse)
        )
        .fetchCurrentWeather(for: CLLocation(latitude: 20.2, longitude: 20.1))

        #expect(weatherResponse.current.temp == 10.99)
    }

    @Test("Test fetching weather with network error")
    func testFetchingWeatherWithNetworkError() async throws {
        let mockNetworkingKitClient = MockNetworkingKitClient(mockError: NetworkingError.badRequest)

        await #expect(throws: NetworkingError.badRequest) {
            _ = try await WeatherRepositoryImplementation(networkingClient: mockNetworkingKitClient)
                .fetchCurrentWeather(for: CLLocation(latitude: 20.2, longitude: 20.1))
        }
    }

    // MARK: - Mock responses

    let mockResponse = OpenWeatherResponse(
        current: Current(dt: Date.now, temp: 10.99, weather: [WeatherInfo(description: "Cold and rainy", main: "Rain", icon: "icon")]),
        hourly: [
            Hourly(dt: Date.now, temp: 10.99, weather: [WeatherInfo(description: "Cold and rainy", main: "Rain", icon: "icon")])
        ],
        daily: [
            Daily(dt: Date.now, temp: Temperature(min: 9, max: 20), weather: [WeatherInfo(description: "Cold and rainy", main: "Rain", icon: "icon")])
        ]
    )
}
