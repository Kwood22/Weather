import Foundation

struct Weather {
    let backgroundImage: String
    let currentConditions: CurrentConditions
    let hourlyForecast: [ForecastedHourlyCondition]
}

struct CurrentConditions {
    let temp: String
    let iconURL: URL
    let description: String
    let minMaxTemp: String
    let city: String
}

struct ForecastedHourlyCondition: Identifiable {
    let id: UUID = .init()
    let temp: String
    let iconURL: URL
    let time: String
}

struct ErrorInformation {
    let title: String
    let description: String
    let button: String
    let actionType: ActionType

    enum ActionType {
        case refresh
        case navigateToSettings
    }
}
