import Foundation

enum Config {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist not found")
        }
        return dict
    }()

    static let apiKey: String = {
        guard let apiKey = Config.infoDictionary["ApiKey"] as? String else {
            fatalError("API key not set in plist")
        }
        return apiKey
    }()

    static let baseAPIUrl: String = {
        guard let apiKey = Config.infoDictionary["BaseApiUrl"] as? String else {
            fatalError("API key not set in plist")
        }
        return apiKey
    }()

    static let baseIconUrl: String = {
        guard let apiKey = Config.infoDictionary["BaseIconUrl"] as? String else {
            fatalError("API key not set in plist")
        }
        return apiKey
    }()
}
