# Weather App
I have created a modular WeatherApp built using Swift, SwiftUI. I am using the MVVM architecture pattern in conjunction with Swift Packages to promote code reusability, clear separation of concerns, independent module development, easy testing, and scalability.

You will see I went an implemented modulatization by creating my own swift packages, I know that this application is simple enough to be a single application without modules but I wanted to show that I have the expertise to create and work in a modular manner.

## Screenshots
| Request Permission | Loading View | Forecast View |
|----------|----------|----------|
| <img src="https://github.com/Kwood22/Weather/blob/main/https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/forecast.png" width="300"/> | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/loading.png" width="300"/> | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/permission.png" width="300"/> |

### Error States:

| Location denied | No internet | 
|----------|----------|
| <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/locationDenied.png" width="300"/> | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/noInternet.png" width="300"/> |

## Run instructions
| Step |  | 
|----------|----------|
| 1. Unzipe the file called WeatherApp-KyleWood.zip and open the foilder called `Weather` | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/folderWeather.png" width="1200" style="float: left;"/> |
| 2. Open the `Weather.xcodeproj` in Xcode | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/folderProj.png" width="1200" style="float: left;"/> |
| 3. Ensure you have an iPhone or simulator selected as the run destination (if you selected your iPhone, please change the project signing to a development certificate) | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/runApp.png" width="1200" style="float: left;"/> |
| 4. Run the app, to install it on a simulator or iphone.  | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/permission.png" width="300" style="float: left;"/> |
| 5. If you selected a simulator, you can simulate different locations by selecting the location icon at the bottom of the xcode screen | <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/simulatorLocation.png" width="1200" style="float: left;"/> |
| 6. Selecting the location icon at the bottom of the xcode screen and picking a location. **Note: it might take two refreshes (clicking on refresh button) to get the updated location from Apple's CoreLocation library.**| <img src="https://github.com/Kwood22/Weather/blob/main/ReadmeAssets/simLocations.png" width="300" style="float: left;"/> |

## 🏗 Architecture Overview
This project follows a modular architecture pattern using Swift Packages as independent modules.
The application is structured using MVVM (Model-View-ViewModel) pattern within a modular setup to promote:
- Code reusability
- Clear separation of concerns
- Independent module development
- Easy testing
- Scalability

You will see there are different `views` but infact I am just replacing the view content in side the `LaunchView`, these extra views are just broken into separate object to encapsulate their logig and functionality.

### Modules Created:

1. **NetworkingKit**

    NetworkingKit is a module that abstracts networking functionality to provide simple networking services to perform networking requests.
    At the moment, the networking module only supports GET requests, but this can be easily modified in the future to provide other requests.

    #### Benefits provided by this module:
    Having networking functionality encapsulated in a single module allows us to reuse networking functionality across different features without having to duplicate code.
    It provides a consistent networking API across different features, making it easier to maintain and update networking functionality in the future.

3. **UtilityKit**

    UtilityKit is a module that abstracts common functionality that is likely to be shared across different features, like location services and connectivity monitoring.

    #### Benefits provided by this module:
    Again, the benefits are similar to the other modules mentioned, most importantly it reduces duplication and increases maintainability.


### App Folder Structure
```
CopyWeatherExample
├── Common
├── Screens
│   ├── Error
│   ├── Forecast
│   └── Launch
├── Networking
├── Package Dependencies
│   ├── NetworkingKit
│   └── LocationKit
├── Tests
```

## 🛠 Testing Overview
I have implemented unit testing for the NetworkingKit, UtilityKit, and ForecastViewModel to ensure that the functionality works as expected, especially
shared functionality exposed by the modules such as networking services.

You can run the tests on each of the modules, by opening the relevant package and running the tests or you can run the app tests from the Weather project.
