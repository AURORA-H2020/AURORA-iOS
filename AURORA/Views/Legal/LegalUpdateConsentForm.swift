import SwiftUI

// MARK: - LegalUpdateConsentForm

/// The LegalUpdateConsentForm
struct LegalUpdateConsentForm {
    
    /// The latest legal documents version.
    let latestLegalDocumentsVersion: Int
    
    /// The user.
    let user: User
    
    /// Bool value if the rejection confirmation dialog is presented.
    @State
    private var isRejectionConfirmationDialogPresented = false
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
    /// The dismiss action
    @Environment(\.dismiss)
    private var dismiss
    
}

// MARK: - View

extension LegalUpdateConsentForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        EmptyPlaceholder(
            systemImage: "info.circle.fill",
            systemImageColor: .accentColor,
            title: "Important",
            subtitle: "We have updated our [Privacy Policy](\(AURORAWebsiteLink.appPrivacyPolicy.absoluteString)) and [Terms of Service](\(AURORAWebsiteLink.appTermsOfServices.absoluteString)). Please review and accept the latest version to continue using the app.",
            primaryAction: .init(title: "Accept") {
                try? self.firebase
                    .firestore
                    .update({
                        var user = self.user
                        user.acceptedLegalDocumentVersion = self.latestLegalDocumentsVersion
                        return user
                    }())
                self.dismiss()
            },
            secondaryAction: .init(title: "Reject") {
                self.isRejectionConfirmationDialogPresented = true
            }
        )
        .confirmationDialog(
            "Warning",
            isPresented: self.$isRejectionConfirmationDialogPresented,
            titleVisibility: .visible,
            actions: {
                Button(role: .destructive) {
                    Task {
                        self.dismiss()
                        try? await self.firebase.authentication.deleteAccount()
                        try? self.firebase.authentication.logout()
                    }
                } label: {
                    Text("Delete Forever")
                }
                Button(role: .cancel) {
                } label: {
                    Text("Go back")
                }
            },
            message: {
                Text(
                    "Rejecting the latest Privacy Policy and Terms of Services requires us to delete your account. Note that we cannot recover your account after deleting it."
                )
            }
        )
    }
    
}
