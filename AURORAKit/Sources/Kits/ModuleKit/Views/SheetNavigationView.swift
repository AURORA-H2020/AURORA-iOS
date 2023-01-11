import SwiftUI

// MARK: - SheetNavigationView

/// A Sheet NavigationView
public struct SheetNavigationView<Content: View> {
    
    // MARK: Properties
    
    /// The Content
    private let content: Content
    
    /// The DismissAction
    @Environment(\.dismiss)
    private var dismiss
    
    // MARK: Initializer
    
    /// Creates a new instance of `SheetNavigationView`
    /// - Parameter content: A ViewBuilder closure that provides the Content
    public init(
        @ViewBuilder
        content: () -> Content
    ) {
        self.content = content()
    }
    
}

// MARK: - View

extension SheetNavigationView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        NavigationView {
            self.content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.dismiss()
                        } label: {
                            Image(
                                systemName: "xmark.circle.fill"
                            )
                            .foregroundColor(.secondary)
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
}
