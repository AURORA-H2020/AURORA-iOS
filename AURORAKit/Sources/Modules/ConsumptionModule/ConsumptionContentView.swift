import SwiftUI

// MARK: - ConsumptionContentView

/// The ConsumptionContentView
public struct ConsumptionContentView {
    
    /// Creates a new instance of `ConsumptionContentView`
    public init() {}
    
}

// MARK: - View

extension ConsumptionContentView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Dashboard")
        }
    }
    
}
