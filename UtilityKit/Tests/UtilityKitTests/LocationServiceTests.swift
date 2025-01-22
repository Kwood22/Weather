import CoreLocation
import Testing
@testable import UtilityKit

@Suite("Location Service Tests")
struct LocationServiceTests {
    @Test("Test locations services sets location correctly")
    func locationServices_setsLocation() async throws {
        let mockLocationManager = MockManger(mockLocation: CLLocation(latitude: 1, longitude: 2))
        let locationService = LocationServiceImplementation(locationManager: mockLocationManager)

        locationService.requestLocation()

        #expect(locationService.location?.coordinate.latitude == 1.0)
        #expect(locationService.error == nil)
    }

    @Test("Test locations services handle authrorization denied")
    func locationServices_handleAuthorizationDenied() async throws {
        let mockLocationManager = MockManger(mockAuthStatus: .denied)
        let locationService = LocationServiceImplementation(locationManager: mockLocationManager)

        locationService.requestLocation()

        #expect(locationService.location == nil)
        #expect(locationService.error?.localizedDescription == LocationServiceError.denied.localizedDescription)
    }

    @Test("Test locations services handle authrorization enabled")
    func locationServices_handleAuthorizationAuthorized() async throws {
        let mockLocationManager = MockManger(mockAuthStatus: .authorizedWhenInUse)
        let locationService = LocationServiceImplementation(locationManager: mockLocationManager)

        locationService.requestLocation()

        #expect(locationService.error == nil)
    }

    @Test("Test locations services  handle location not found")
    func locationServices_handleNoLocation() async throws {
        let mockLocationManager = MockManger(testNoLocations: true)
        let locationService = LocationServiceImplementation(locationManager: mockLocationManager)

        locationService.requestLocation()

        #expect(locationService.location == nil)
        #expect(locationService.error?.localizedDescription == LocationServiceError.noLocationFound.localizedDescription)
    }

    @Test("Test locations services handles an CLError error correctly")
    func locationServices_handleCLError() async throws {
        let mockLocationManager = MockManger(mockError: CLError(CLError.network, userInfo: [:]))
        let locationService = LocationServiceImplementation(locationManager: mockLocationManager)

        locationService.requestLocation()

        #expect(locationService.location == nil)
        #expect(locationService.error?.localizedDescription == LocationServiceError.unknown(error: CLError(CLError.network, userInfo: [:])).localizedDescription)
    }

    @Test("Test locations services handles an unknown error correctly")
    func locationServices_handleUnknownError() async throws {
        let mockLocationManager = MockManger(mockError: SomeOtherError.someOtherError)
        let locationService = LocationServiceImplementation(locationManager: mockLocationManager)

        locationService.requestLocation()

        #expect(locationService.location == nil)
        #expect(locationService.error?.localizedDescription == LocationServiceError.unknown(error: SomeOtherError.someOtherError).localizedDescription)
    }

    @Test("Test locations services get city name correctly")
    func locationServices_getCityName() async throws {
        let locationService = LocationServiceImplementation(locationManager: MockManger())

        let cityName = await locationService.getCityName(location: CLLocation(latitude: -26.195246, longitude: 28.034088))

        #expect(cityName == "Johannesburg")
    }

    @Test("Test locations services get city name handles invalid location")
    func locationServices_getCityNameForInvalidLocation() async throws {
        let locationService = LocationServiceImplementation(locationManager: MockManger())

        let cityName = await locationService.getCityName(location: CLLocation(latitude: -1000000, longitude: 100000000))

        #expect(cityName == nil)
    }
}

enum SomeOtherError: Error {
    case someOtherError
}

