import SwiftUI

// MARK: - SignInWithGoogleButton

/// The Sign in with Google Button
struct SignInWithGoogleButton {
    
    /// The action to perform when the user triggers the button.
    let action: () -> Void
    
}

// MARK: - View

extension SignInWithGoogleButton: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Button {
            self.action()
        } label: {
            HStack {
                Spacer()
                Image(
                    "google",
                    bundle: .module
                )
                .imageScale(.small)
                Text(
                    verbatim: "Continue with Google"
                )
                .font(.callout)
                Spacer()
            }
            .foregroundColor(.gray)
        }
        .buttonStyle(.borderedProminent)
        .tint(.white)
    }
    
}
