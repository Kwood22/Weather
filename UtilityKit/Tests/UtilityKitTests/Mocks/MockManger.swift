import CoreLocation

class MockManger: CLLocationManager {
    var mockLocation: CLLocation?
    var mockError: Error?
    var mockAuthStatus: CLAuthorizationStatus?
    var testNoLocations: Bool

    override var authorizationStatus: CLAuthorizationStatus {
        mockAuthStatus ?? .authorizedWhenInUse
    }

    init(mockLocation: CLLocation? = nil, mockError: Error? = nil, mockAuthStatus: CLAuthorizationStatus? = nil, testNoLocations: Bool = false) {
        self.mockLocation = mockLocation
        self.mockError = mockError
        self.mockAuthStatus = mockAuthStatus
        self.testNoLocations = testNoLocations
    }

    override func requestWhenInUseAuthorization() {
        if let mockAuthStatus {
            delegate?.locationManagerDidChangeAuthorization?(self)
            return
        }

        if let mockError {
            delegate?.locationManager?(self, didFailWithError: mockError)
        }

        if let mockLocation {
            delegate?.locationManager?(self, didUpdateLocations: [mockLocation])
            return
        }

        if testNoLocations {
            delegate?.locationManager?(self, didUpdateLocations: [])
            return
        }
    }

    override func requestLocation() {
        if let mockLocation {
            delegate?.locationManager?(self, didUpdateLocations: [mockLocation])
            return
        }

        if let mockError {
            delegate?.locationManager?(self, didFailWithError: mockError)
        }
    }
}
