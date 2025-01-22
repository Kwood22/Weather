import CoreLocation
import NetworkingKit
import SwiftUI
import UtilityKit

struct ForecastView: View {
    @State var viewModel: ForecastViewModel
    @State var locationService: LocationService
    @State private var offset: CGFloat = 0

    init(
        locationService: LocationService,
        weatherRepository: WeatherRepository = WeatherRepositoryImplementation()
    ) {
        _locationService = .init(initialValue: locationService)
        viewModel = ForecastViewModelImpl(
            weatherRepository: weatherRepository,
            locationService: locationService
        )
    }

    var body: some View {
        ZStack {
            switch viewModel.weatherForecast {
            case .loading:
                ProgressView()
            case .loaded(let weather):
                backgroundImage(url: weather.backgroundImage)
                VStack(spacing: 20) {
                    currentWeatherConditions(weather.currentConditions)
                    Spacer()
                    VStack {
                        Text("Hourly Forecast")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        hourlyForecast(weather.hourlyForecast)
                    }
                    bottomRefreshButton()
                }
            case .error(let error):
                ErrorView(
                    heading: error.title,
                    description: error.description,
                    buttonText: error.button
                ) {
                    locationService.requestLocation()
                    refreshForecast()
                }
            }
        }
        .task {
            await viewModel.fetchForecast(location: locationService.location)
        }
    }

    // MARK: - View Components

    private func backgroundImage(url: String) -> some View {
        Image(url)
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
            .overlay {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
            }
    }

    private func currentWeatherConditions(_ currentConditions: CurrentConditions) -> some View {
        VStack(spacing: 10) {
            imageWithPlaceholder(url: currentConditions.iconURL, size: 80)
                .padding(.top, 60)

            if !currentConditions.city.isEmpty {
                Text(currentConditions.city)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
            }

            Text(currentConditions.temp)
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)

            Text(currentConditions.description)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(currentConditions.minMaxTemp)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }

    private func hourlyForecast(_ Forecast: [ForecastedHourlyCondition]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Forecast, id: \.id) { hourlyForecast in
                    VStack(spacing: 15) {
                        Text(hourlyForecast.temp)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        imageWithPlaceholder(url: hourlyForecast.iconURL, size: 30)
                        Text("\(hourlyForecast.time)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(width: 70)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }

    private func bottomRefreshButton() -> some View {
        HStack {
            Spacer()
            Button(
                "Refresh",
                systemImage: "arrow.clockwise",
                action: {
                    locationService.requestLocation()
                    refreshForecast()
                }
            )
            .buttonStyle(PillButtonStyle(colors: [.white.opacity(0.4)]))
            Spacer()
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 10)
    }

    private func imageWithPlaceholder(url: URL, size: CGFloat) -> some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .foregroundColor(.white)
            } else if phase.error != nil {
                Text("No image available")
            } else {
                ProgressView()
            }
        }
        .frame(width: size, height: size, alignment: .center)
    }

    private func refreshForecast() {
        Task {
            await viewModel.fetchForecast(location: locationService.location)
        }
    }
}

#Preview {
    ForecastView(
        locationService: LocationServiceImplementation(),
        weatherRepository: WeatherRepositoryImplementation()
    )
}
