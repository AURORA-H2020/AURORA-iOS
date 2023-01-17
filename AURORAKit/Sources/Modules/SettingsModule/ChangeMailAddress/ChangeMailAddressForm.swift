import FirebaseKit
import ModuleKit
import SwiftUI

// MARK: - ChangeMailAddressView

/// The ChangeMailAddressForm
struct ChangeMailAddressForm {
    
    /// The mail address
    @State
    private var mailAddress = String()
    
    /// The dismiss action
    @Environment(\.dismiss)
    private var dismiss
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

private extension ChangeMailAddressForm {
    
    var canSubmit: Bool {
        !self.mailAddress.isEmpty
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
        case .failure(let error):
            if (error as? FirebaseKit.AuthErrorCode)?.code == .requiresRecentLogin {
                return .init(
                    title: .init(
                        verbatim: "Recent login required"
                    ),
                    message: .init(
                        verbatim: "A recent login is required in order to change your E-Mail address."
                    )
                )
            } else {
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
    
}

// MARK: - View

extension ChangeMailAddressForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section(
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
                    "E-Mail address",
                    text: self.$mailAddress
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
            }
            .headerProminence(.increased)
            Section(
                footer: AsyncButton(
                    alert: self.alert,
                    action: {
                        try await self.firebase
                            .authentication
                            .update(
                                email: self.mailAddress
                            )
                    },
                    label: {
                        Text(
                            verbatim: "Submit"
                        )
                        .font(.headline)
                        .padding(.horizontal)
                    }
                )
                .disabled(!self.canSubmit)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .align(.centerHorizontal)
            ) {
            }
        }
        .navigationTitle("Change E-Mail")
    }
    
}
