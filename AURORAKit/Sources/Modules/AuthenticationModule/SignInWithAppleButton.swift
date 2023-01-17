import SwiftUI

// MARK: - SignInWithAppleButton

/// The Sign in with Apple Button
struct SignInWithAppleButton {
    
    /// The action to perform when the user triggers the button.
    let action: () -> Void
    
    /// The color scheme
    @Environment(\.colorScheme)
    private var colorScheme
    
}

// MARK: - View

extension SignInWithAppleButton: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Button {
            self.action()
        } label: {
            HStack {
                Spacer()
                Image(
                    systemName: "apple.logo"
                )
                .imageScale(.small)
                Text(
                    verbatim: "Continue with Apple"
                )
                .font(.callout)
                Spacer()
            }
            .foregroundColor(self.colorScheme == .dark ? .black : .white)
        }
        .buttonStyle(.borderedProminent)
        .tint(self.colorScheme == .dark ? .white : .black)
    }
    
}
