import Foundation

struct OpenWeatherResponse: Codable {
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
}

struct Current: Codable {
    let dt: Date
    let temp: Double
    let weather: [WeatherInfo]
}

struct Hourly: Codable {
    let dt: Date
    let temp: Double
    let weather: [WeatherInfo]
}

struct Daily: Codable {
    let dt: Date
    let temp: Temperature
    let weather: [WeatherInfo]
}

struct Temperature: Codable {
    let min: Double
    let max: Double
}

struct WeatherInfo: Codable {
    let description: String
    let main: String
    let icon: String
}
