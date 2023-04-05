import SwiftUI

// MARK: - ChangeMailAddressView

/// The ChangeMailAddressForm
struct ChangeMailAddressForm {
    
    /// The mail address
    @State
    private var mailAddress = String()
    
    /// The password
    @State
    private var password = String()
    
    /// The dismiss action
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension ChangeMailAddressForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
                header: Text("New email address"),
                footer: Group {
                    if let email = try? self.firebase.authentication.state.userAccount.email {
                        Text("Current email address:\n\(email)")
                            .multilineTextAlignment(.leading)
                    }
                }
            ) {
                TextField(
                    "New email address",
                    text: self.$mailAddress
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
            }
            .headerProminence(.increased)
            Section(
                header: Text("Password"),
                footer: Text("Enter your current password.")
            ) {
                SecureField(
                    "Password",
                    text: self.$password
                )
                .textContentType(.password)
            }
            .headerProminence(.increased)
            Section(
                footer: AsyncButton(
                    fillWidth: true,
                    alert: self.alert,
                    action: {
                        try await self.firebase
                            .authentication
                            .updateMailAddress(
                                newMailAddress: self.mailAddress,
                                currentPassword: self.password
                            )
                    },
                    label: {
                        Text("Submit")
                            .font(.headline)
                    }
                )
                .disabled(self.password.isEmpty || !self.mailAddress.isMailAddress)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
            ) {
            }
        }
        .navigationTitle("Change email")
    }
    
}

private extension ChangeMailAddressForm {
    
    func alert(
        for result: Result<Void, Error>
    ) -> Alert? {
        switch result {
        case .success:
            return .init(
                title: Text("Email address changed"),
                message: Text("Your email address has successfully been changed."),
                dismissButton: .default(
                    Text("Okay"),
                    action: self.dismiss.callAsFunction
                )
            )
        case .failure:
            return .init(
                title: Text("Error"),
                message: Text(
                    "An error occurred while trying to update your email address. Please check your inputs and try again."
                )
            )
        }
    }
    
}
