import FirebaseKit
import SwiftUI

// MARK: - SettingsContentView

/// The SettingsContentView
public struct SettingsContentView {
    
    // MARK: Properties
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `SettingsContentView`
    public init() {}
    
}

// MARK: - View

extension SettingsContentView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        NavigationView {
            List {
                Button(role: .destructive) {
                    try? self.firebase.logout()
                } label: {
                    Text(verbatim: "Logout")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
}
