import SwiftUI

// MARK: - FeaturePreview

/// The FeaturePreview
struct FeaturePreview {
    
}

// MARK: - View

extension FeaturePreview: View {
    
    /// The content and behavior of the view.
    var body: some View {
        TabView {
            Page(
                imageName: "Feature-Preview-Dashboard",
                // swiftlint:disable:next line_length
                description: "Once our solar installations go live in each demo site you can track the energy production right from the app."
            )
            Page(
                imageName: "Feature-Preview-Tasks",
                // swiftlint:disable:next line_length
                description: "Get an overview of your latest submitted data, pending entry requests, and how you can improve your carbon footprint accuracy."
            )
            Page(
                imageName: "Feature-Preview-My-Data",
                // swiftlint:disable:next line_length
                description: "We are working on expanding your profile data with the addition of households, personalised vehicles, energy sources, and more."
            )
        }
        .tabViewStyle(.page)
        .navigationTitle("Feature Preview")
    }
    
}
