import SwiftData
import SwiftUI
import UtilityKit

struct LaunchView: View {
    @State private var locationService = LocationServiceImplementation()
    @State private var networkMonitor = NetworkMonitor.shared
    @State var isLoading: Bool = true
    @State var showNetWorkNotAvailable: Bool = false

    var body: some View {
        ZStack {
            if showNetWorkNotAvailable {
                getNoInternetConnectionView()
            } else {
                getContentForLocation()
                    .task {
                        isLoading = true
                        locationService.requestLocation()
                    }
            }
        }.onChange(of: networkMonitor.isConnected) { _, newValue in
            showNetWorkNotAvailable = !newValue
        }
    }

    // MARK: - View Components

    func getContentForLocation() -> some View {
        ZStack {
            if let error = locationService.error {
                errorViewForLocationIssues(fetchErrorInformation(for: error))
            } else if locationService.location != nil {
                ForecastView(locationService: locationService)
            } else if isLoading {
                ProgressView()
            }
        }
    }

    func getNoInternetConnectionView() -> some View {
        ContentUnavailableView(
            "No Internet Connection",
            systemImage: "wifi.exclamationmark",
            description: Text("Please check your connection and try again.")
        )
    }

    func errorViewForLocationIssues(_ error: ErrorInformation) -> some View {
        ErrorView(
            heading: error.title,
            description: error.description,
            buttonText: error.button
        ) {
            switch error.actionType {
            case .refresh:
                isLoading = true
                locationService.requestLocation()
            case .navigateToSettings:
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!
                )
            }
        }
    }

    // MARK: - Helper functions

    private func fetchErrorInformation(for error: LocationServiceError) -> ErrorInformation {
        isLoading = false
        return switch error {
        case .denied, .restricted:
            ErrorInformation(
                title: "Location access disabled",
                description: "Location access might have been disabled, please enable it in settings, we need your location to provide you with accurate weather information",
                button: "GO TO SETTINGS",
                actionType: .navigateToSettings
            )

        case .noLocationFound:
            ErrorInformation(
                title: "A location error occured",
                description: "An error occured while fetching your location data, please trying again.",
                button: "RETRY",
                actionType: .refresh
            )

        case .unknown(error: let error):
            ErrorInformation(
                title: "A unknown location error occured",
                description: "An error occured while fetching your location data, \(error.localizedDescription)",
                button: "RETRY",
                actionType: .refresh
            )
        }
    }
}

#Preview {
    NavigationStack {
        LaunchView()
    }
}
