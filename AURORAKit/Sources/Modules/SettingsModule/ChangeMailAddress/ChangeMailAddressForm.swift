import FirebaseKit
import ModuleKit
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
                header: Text(verbatim: "New E-Mail address"),
                footer: Group {
                    if let email = try? self.firebase.authentication.state.userAccount.email {
                        Text(
                            verbatim: "Current E-Mail address:\n\(email)"
                        )
                        .multilineTextAlignment(.leading)
                    }
                }
            ) {
                TextField(
                    "New E-Mail address",
                    text: self.$mailAddress
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
            }
            .headerProminence(.increased)
            Section(
                header: Text(verbatim: "Password"),
                footer: Text(verbatim: "Enter your current password.")
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
                        Text(
                            verbatim: "Submit"
                        )
                        .font(.headline)
                    }
                )
                .disabled(MailAddress(self.mailAddress) == nil || self.password.isEmpty)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
            ) {
            }
        }
        .navigationTitle("Change E-Mail")
    }
    
}

private extension ChangeMailAddressForm {
    
    func alert(
        for result: Result<Void, Error>
    ) -> Alert? {
        switch result {
        case .success:
            return .init(
                title: .init(
                    verbatim: "E-Mail address changed"
                ),
                message: .init(
                    verbatim: "Your E-Mail address has successfully been changed."
                ),
                dismissButton: .default(
                    Text(verbatim: "Okay"),
                    action: self.dismiss.callAsFunction
                )
            )
        case .failure:
            return .init(
                title: .init(
                    verbatim: "Error"
                ),
                message: .init(
                    // swiftlint:disable:next line_length
                    verbatim: "An error occurred while trying to update your E-Mail address. Please check your inputs and try again."
                )
            )
        }
    }
    
}
