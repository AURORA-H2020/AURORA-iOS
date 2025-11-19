![AURORA Project Banner](https://www.aurora-h2020.eu/wp-content/uploads/2022/08/Logo-Website.png)

# AURORA iOS App

[![Upload to TestFlight](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/upload_to_test_flight.yml/badge.svg)](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/upload_to_test_flight.yml)
[![Upload Localizations to LingoHub](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/upload_localizations_to_lingo_hub.yml/badge.svg)](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/upload_localizations_to_lingo_hub.yml)
[![Import Localizations from LingoHub](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/import_localizations_from_lingo_hub.yml/badge.svg)](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/import_localizations_from_lingo_hub.yml)
[![Generate Screenshots](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/generate_screenshots.yml/badge.svg)](https://github.com/AURORA-H2020/AURORA-iOS/actions/workflows/generate_screenshots.yml)

**[Website](https://www.aurora-h2020.eu/) | [Download App](https://apps.apple.com/us/app/aurora-energy-tracker/id1668801198)**

## About the Project

**AURORA** is a pioneering Innovation Action funded by the EU’s **Horizon 2020** programme. Starting in December 2021 with €4.6 million in funding, AURORA aims to demonstrate how ordinary citizens can drive the transition to a near-zero emission society.

The project engages approximately **7,000 citizens** across five locations (Denmark, England, Portugal, Slovenia, and Spain) to become "citizen scientists." These communities are not only reducing their own carbon footprint but are also crowd-funding local **photovoltaic (PV) facilities** to produce ~1 megawatt of renewable energy.

This iOS application is a central tool in the AURORA ecosystem, enabling participants to:
*   Monitor their energy-related behaviors (heating, cooling, transport, electricity).
*   Receive tailored suggestions to lower energy demand and costs.
*   Track the impact of their community's renewable energy generation.

## Key Features

* **Personal Emissions Profile:** Enter your energy consumptions for electricity, heating, and transportation to create a comprehensive carbon footprint profile unique to your lifestyle.
* **Track Energy Usage:** Monitor and visualise your carbon footprint and energy usage trends over time, gaining valuable insights into your environmental impact.
* **Energy Labels:** Receive energy labels based on your consumptions and discover ways to lower your usage, improving your labels and actively reducing your environmental impact.
* **Track Local Photovoltaic:** Add your contribution to AURORA demo sites' solar power installations and automatically offset your emissions.
* **Personalised Recommendations:** Receive helpful tips and recommendations based on your consumption data for improving your energy behaviour.

## Tech Stack

The AURORA iOS app is built with modern iOS development practices, leveraging **SwiftUI** for UI and **Firebase** for backend services.

*   **Language**: [Swift](https://developer.apple.com/swift/)
*   **Minimum iOS Version**: iOS 16.0
*   **UI Framework**: [SwiftUI](https://developer.apple.com/xcode/swiftui/)
*   **Architecture**: MVVM (Model-View-ViewModel)
*   **Dependency Injection**: Native (EnvironmentObject)
*   **Networking**: [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
*   **Backend / Cloud**:
    *   [Firebase Authentication](https://firebase.google.com/docs/auth)
    *   [Firebase Firestore](https://firebase.google.com/docs/firestore)
    *   [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
    *   [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
    *   [Firebase Remote Config](https://firebase.google.com/docs/remote-config)
*   **Charting**: [Swift Charts](https://developer.apple.com/documentation/charts)
*   **Navigation**: SwiftUI Navigation

## Installation & Setup

### Prerequisites
*   [Xcode](https://developer.apple.com/xcode/) (Latest version recommended)
*   iOS 16.0+ Simulator or Device

### Getting Started

1.  **Clone the repository**
    ```bash
    git clone https://github.com/AURORA-H2020/AURORA-iOS.git
    cd AURORA-iOS
    ```

2.  **Firebase Configuration**
    *   This project relies on Firebase. You will need a `GoogleService-Info.plist` file.
    *   Place your `GoogleService-Info.plist` file in the `AURORA/Resources/` directory (or where the project expects it, typically added to the Xcode target).
    *   *Note: If you are a core developer, ask the project lead for the development environment credentials.*

3.  **Open the Project**
    Open `AURORA.xcodeproj` in Xcode.

4.  **Build and Run**
    Select a simulator or connected device and press **Cmd + R** to build and run the app.

## Project Structure

The project follows a modular structure within the `AURORA` directory:

*   `AURORA`
    *   `App.swift`: The main entry point of the application.
    *   `AppDelegate.swift`: Application delegate for Firebase configuration and lifecycle events.
    *   `Models`: Data models and entities.
    *   `Services`: Backend integration, API calls, and business logic services.
    *   `Views`: SwiftUI Views organized by feature.
        *   `Authentication`: Login and registration screens.
        *   `Consumption`: Energy tracking and monitoring screens.
        *   `Photovoltaic`: PV plant monitoring and charts.
        *   `Settings`: User settings and configuration.
        *   `User`: User profile management.
    *   `Resources`: Assets, Localization, and Info.plist.

## The Project Consortium

The AURORA project is a collaboration between nine institutions across six countries:

*   **Technical University of Madrid** (Spain) - Project Coordinator
*   **Aarhus University** (Denmark)
*   **Centre for Sustainable Energy** (United Kingdom)
*   **Forest of Dean District Council** (United Kingdom)
*   **Institute for Science & Innovation Communication** (Germany)
*   **KempleyGreen Consultants** (United Kingdom)
*   **Qualifying Photovoltaics** (Spain)
*   **University of Ljubljana** (Slovenia)
*   **University of Évora** (Portugal)

## License & Funding

This project is part of the AURORA initiative.

<img src="https://www.aurora-h2020.eu/wp-content/uploads/elementor/thumbs/EU-Flag-psu6pdbcnlpmaljtwxkotmokm7piv22d31neeas0vc.png" width="100" align="left" style="margin-right: 20px;" />

**Funded by the European Union.**
This project has received funding from the European Union’s **Horizon 2020** research and innovation programme under grant agreement No **[101036418](https://cordis.europa.eu/project/id/101036418)**.
