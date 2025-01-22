import CoreLocation
import NetworkingKit
import Observation
import SwiftUICore
import UtilityKit

protocol ForecastViewModel {
    var weatherForecast: Loadable<Weather, ErrorInformation> { get }
    func fetchForecast(location: CLLocation?) async
}

enum ForecastError: Error {
    case noLocation
    case mappingError
}

@Observable
class ForecastViewModelImpl: ForecastViewModel {
    var weatherForecast: Loadable<Weather, ErrorInformation> = .loading

    private let weatherRepository: WeatherRepository
    private let locationService: LocationService

    init(weatherRepository: WeatherRepository, locationService: LocationService) {
        self.weatherRepository = weatherRepository
        self.locationService = locationService
    }

    func fetchForecast(location: CLLocation?) async {
        weatherForecast = .loading
        guard let location else {
            debugPrint("No location available")
            handleError(error: ForecastError.noLocation)
            return
        }

        do {
            let response = try await weatherRepository.fetchCurrentWeather(for: location)
            let cityName = await locationService.getCityName(location: location) ?? ""
            guard let weather = convertResponseToWeather(response, city: cityName) else {
                handleError(error: ForecastError.mappingError)
                return
            }
            weatherForecast = .loaded(weather)
        } catch {
            debugPrint("And unkwown error occurred \(error)")
            handleError(error: error)
        }
    }

    // MARK: - Helper functions

    private func convertResponseToWeather(_ response: OpenWeatherResponse, city: String) -> Weather? {
        guard let currentDayWeatherResponse = response.daily.first(
            where: { Calendar.current.isDate(response.current.dt, equalTo: $0.dt, toGranularity: .day) }
        ) else {
            debugPrint("WeatherService: There was no matching daily Forecast for the current date")
            return nil
        }

        let currentCondition = CurrentConditions(
            temp: getTempString(for: response.current.temp),
            iconURL: getIconURL(for: response.current.weather[0].icon),
            description: response.current.weather[0].description,
            minMaxTemp: "Max: \(getTempString(for: currentDayWeatherResponse.temp.max)) Min: \(getTempString(for: currentDayWeatherResponse.temp.min))",
            city: city
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let hourlyForecast = response.hourly.prefix(24).map {
            ForecastedHourlyCondition(
                temp: getTempString(for: $0.temp),
                iconURL: getIconURL(for: $0.weather[0].icon),
                time: "\(formatter.string(from: $0.dt))"
            )
        }
        let backgroundImage = getBackgroundImage(for: response.current.weather[0].main)

        return Weather(
            backgroundImage: backgroundImage,
            currentConditions: currentCondition,
            hourlyForecast: hourlyForecast
        )
    }

    private func getTempString(for temp: Double) -> String {
        "\(temp.rounded())°"
    }

    private func getIconURL(for icon: String) -> URL {
        URL(string: "\(Config.baseIconUrl)\(icon)@2x.png")!
    }

    private func getBackgroundImage(for weatherCondition: String) -> String {
        switch weatherCondition.lowercased() {
        case "clear":
            "sunnyImage"
        case "clouds":
            "cloudyImage"
        case "drizzle", "fog", "rain":
            "rainyImage"
        case "snow":
            "snowyImage"
        case "thunderstorm":
            "stormyImage"
        default:
            "sunnyImage"
        }
    }

    private func handleError(error: Error) {
        debugPrint("Error: \(error.localizedDescription)")
        let errorInformation = switch error {
        case is NetworkingError:
            ErrorInformation(
                title: "A network error occured",
                description: "An error occured while fetching weather data, please trying again.",
                button: "RETRY",
                actionType: .refresh
            )
        case is ForecastError:
            if error as? ForecastError == .noLocation {
                ErrorInformation(
                    title: "No location found",
                    description: "An error occured while fetching your location, check your location permisions and try again.",
                    button: "RETRY",
                    actionType: .refresh
                )
            } else {
                ErrorInformation(
                    title: "A internal error occured",
                    description: "An error occured while fetching weather data, please trying again.",
                    button: "RETRY",
                    actionType: .refresh
                )
            }
        default:
            ErrorInformation(
                title: "A unknown error occured",
                description: "An error occured while fetching weather data, please trying again.",
                button: "RETRY",
                actionType: .refresh
            )
        }

        weatherForecast = .error(errorInformation)
    }
}
