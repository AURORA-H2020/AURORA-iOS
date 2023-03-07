import SwiftUI

// MARK: - PhotovoltaicScreen

/// The PhotovoltaicScreen
struct PhotovoltaicScreen {
    
    /// The Country
    let country: Country
    
}

// MARK: - View

extension PhotovoltaicScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Photovoltaics")
        }
    }
    
}
