import CoreLocation
import Observation

public enum LocationServiceError: Error {
    case noLocationFound
    case restricted
    case denied
    case unknown(error: Error)
}

public protocol LocationService: Observable {
    var location: CLLocation? { get }
    var error: LocationServiceError? { get }
    func getCityName(location: CLLocation) async -> String?
    func requestLocation()
}

@Observable
public final class LocationServiceImplementation: NSObject, LocationService {
    public var location: CLLocation?
    public var error: LocationServiceError?
    private let manager: CLLocationManager

    public init(locationManager: CLLocationManager = CLLocationManager()) {
        self.manager = locationManager
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
    }

    public func requestLocation() {
        manager.requestLocation()
    }

    public func getCityName(location: CLLocation) async -> String? {
        let geoCoder = CLGeocoder()
        return try? await geoCoder.reverseGeocodeLocation(location).first?.locality
    }
}

extension LocationServiceImplementation: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        location = nil
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .restricted {
            error = nil
            requestLocation()
        } else {
            error = .denied
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            debugPrint("UtilityKit: Location service error")
            error = .noLocationFound
            return
        }
        error = nil
        self.location = location
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("UtilityKit: Location service error: \(error.localizedDescription)")
        location = nil
        guard let locationError = error as? CoreLocation.CLError else {
            self.error = .unknown(error: error)
            return
        }

        if locationError.errorCode == CLError.Code.denied.rawValue {
            self.error = .denied
        } else {
            self.error = .unknown(error: locationError)
        }
    }
}
