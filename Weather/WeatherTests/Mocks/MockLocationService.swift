import CoreLocation
import UtilityKit

struct MockLocationService: LocationService {
    func requestLocation() {}

    func getCityName(location: CLLocation) async -> String? {
        "Test"
    }

    var error: LocationServiceError?
    var location: CLLocation?

    init(error: LocationServiceError? = nil, location: CLLocation? = nil) {
        self.error = error
        self.location = location
    }
}
