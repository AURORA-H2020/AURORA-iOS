import ModuleKit
import SwiftUI

// MARK: - AuthenticationProviderButton

/// An authentication provider button
struct AuthenticationProviderButton {
    
    // MARK: Static-Properties
    
    /// The preferred stack spacing.
    static let preferredStackSpacing: CGFloat = 16
    
    // MARK: Properties
    
    /// The Style.
    let style: Style
    
    /// The action to perform when the user triggers the button.
    let action: () -> Void
    
    /// The UIImpactFeedbackGenerator
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    /// The color scheme
    @Environment(\.colorScheme)
    private var colorScheme
    
}

// MARK: - View

extension AuthenticationProviderButton: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Button {
            // Invoke impact feedback
            self.impactFeedbackGenerator.impactOccurred()
            // Invoke action
            self.action()
        } label: {
            Label {
                Text(
                    verbatim: "Continue with \(self.style.rawValue)"
                )
                .font(.headline.weight(.medium))
            } icon: {
                self.style.icon
            }
            .foregroundColor(
                self.style
                    .foregroundColor(colorScheme: self.colorScheme)
            )
            .align(.centerHorizontal)
            .frame(minHeight: 36)
        }
        .buttonStyle(.borderedProminent)
        .tint(
            self.style
                .tintColor(colorScheme: self.colorScheme)
        )
        .overlay {
            if let borderColor = self.style.borderColor(colorScheme: self.colorScheme) {
                RoundedRectangle(
                    cornerRadius: 8
                )
                .stroke(
                    borderColor,
                    lineWidth: 1
                )
            }
        }
        .onAppear {
            // Prepare impact feedback generator
            self.impactFeedbackGenerator.prepare()
        }
    }
    
}
