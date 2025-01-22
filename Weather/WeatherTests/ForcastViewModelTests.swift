import CoreLocation
import NetworkingKit
import Testing
@testable import Weather

@Suite("ForecastViewModel tests") struct ForecastViewModelTests {
    @Test("Fetching Weather Forecast")
    func FetchingWeatherForecast_success() async throws {
        let mockLocationService = MockLocationService(location: CLLocation(latitude: 12, longitude: 14))
        let viewModel = ForecastViewModelImpl(
            weatherRepository: MockWeatherRepository(),
            locationService: mockLocationService
        )

        await viewModel.fetchForecast(location: mockLocationService.location)

        let forecast: Weather? = switch viewModel.weatherForecast {
        case .loaded(let Forecast):
            Forecast
        default:
            nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let expectedTime = dateFormatter.string(from: .now)

        #expect(forecast != nil)
        #expect(forecast?.currentConditions.temp == "11.0°")
        #expect(forecast?.currentConditions.minMaxTemp == "Max: 20.0° Min: 9.0°")
        #expect(forecast?.backgroundImage == "rainyImage")
        #expect(forecast?.hourlyForecast.count == 1)
        #expect(forecast?.hourlyForecast.first?.temp == "11.0°")
        #expect(forecast?.hourlyForecast.first?.time == expectedTime)
        #expect(forecast?.hourlyForecast.first?.iconURL.absoluteString == "https://openweathermap.org/img/wn/icon@2x.png")
    }

    @Test("Fetching Weather forecast but no lcoation found then handle error")
    func testFetchingWeatherForecastErrorHandling_noLocation() async throws {
        let mockLocationService = MockLocationService()
        let viewModel = ForecastViewModelImpl(
            weatherRepository: MockWeatherRepository(),
            locationService: mockLocationService
        )
        await viewModel.fetchForecast(location: mockLocationService.location)
        let error: ErrorInformation? = switch viewModel.weatherForecast {
        case .error(let error):
            error
        default:
            nil
        }
        #expect(error != nil)
        #expect(error?.title == "No location found")
        #expect(error?.actionType == .refresh)
        #expect(error?.button == "RETRY")
    }

    @Test("Fetching Weather forecast but network error occurs then handle error")
    func testFetchingWeatherForecastErrorHandling_NetworkError() async throws {
        let mockLocationService = MockLocationService(location: CLLocation(latitude: 12, longitude: 14))
        let viewModel = ForecastViewModelImpl(
            weatherRepository: MockWeatherRepository(errorType: .network),
            locationService: mockLocationService
        )
        await viewModel.fetchForecast(location: mockLocationService.location)
        let error: ErrorInformation? = switch viewModel.weatherForecast {
        case .error(let error):
            error
        default:
            nil
        }
        #expect(error != nil)
        #expect(error?.title == "A network error occured")
        #expect(error?.actionType == .refresh)
        #expect(error?.button == "RETRY")
    }

    @Test("Fetching Weather Forecast other error handling") func testFetchingWeatherForecastErrorHandling_OtherError() async throws {
        let mockLocationService = MockLocationService(location: CLLocation(latitude: 12, longitude: 14))
        let viewModel = ForecastViewModelImpl(
            weatherRepository: MockWeatherRepository(errorType: .other),
            locationService: mockLocationService
        )
        await viewModel.fetchForecast(location: mockLocationService.location)
        let error: ErrorInformation? = switch viewModel.weatherForecast {
        case .error(let error):
            error
        default:
            nil
        }
        #expect(error != nil)
        #expect(error?.title == "A unknown error occured")
    }
}

