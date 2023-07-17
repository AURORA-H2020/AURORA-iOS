import FirebaseAnalyticsSwift
import FirebaseAuth
import SwiftUI

// swiftlint:disable file_length

// MARK: - SettingsScreen

/// The SettingsScreen
struct SettingsScreen {
    
    /// Bool value if change mail address form is presented
    @State
    private var isChangeMailAddressFormPresented = false
    
    /// Bool value if change password form is presented
    @State
    private var isChangePasswordFormPresented = false
    
    /// The RecurringConsumptionsReminderService
    @StateObject
    private var recurringConsumptionsReminderService: RecurringConsumptionsReminderService = .shared
    
    /// The Firebase instance
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension SettingsScreen: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationView {
            List {
                self.accountSection
                self.notificationsSection
                self.privacySection
                self.supportSection
                self.legalSection
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
        .analyticsScreen(
            name: "Settings",
            class: "SettingsView"
        )
        .sheet(
            isPresented: self.$isChangeMailAddressFormPresented
        ) {
            SheetNavigationView {
                ChangeMailAddressForm()
            }
            .environmentObject(self.firebase)
        }
        .sheet(
            isPresented: self.$isChangePasswordFormPresented
        ) {
            SheetNavigationView {
                ChangePasswordForm()
            }
            .environmentObject(self.firebase)
        }
    }
    
}

// MARK: - Account Section

private extension SettingsScreen {
    
    /// The account section.
    var accountSection: some View {
        Section(
            header: Text("Account")
        ) {
            if let user = try? self.firebase.user?.get() {
                NavigationLink(
                    destination: EditUserForm(
                        user: user
                    )
                ) {
                    Label(
                        "Edit profile",
                        systemImage: "person.crop.circle"
                    )
                }
            }
            if (try? self.firebase.authentication.providers.contains(.password)) == true {
                Button {
                    self.isChangeMailAddressFormPresented = true
                } label: {
                    Label(
                        "Change email",
                        systemImage: "envelope"
                    )
                }
                Button {
                    self.isChangePasswordFormPresented = true
                } label: {
                    Label(
                        "Change Password",
                        systemImage: "key"
                    )
                }
            }
            AsyncButton(
                confirmationDialog: { action in
                    .init(
                        title: Text("Logout"),
                        message: Text("Are you sure you want to logout?"),
                        buttons: [
                            .destructive(
                                Text("Logout"),
                                action: action
                            ),
                            .cancel()
                        ]
                    )
                },
                alert: { result in
                    guard case .failure = result else {
                        return nil
                    }
                    return .init(
                        title: Text("Error"),
                        message: Text("An error occurred while trying to logout.")
                    )
                },
                action: {
                    try self.firebase.authentication.logout()
                },
                label: {
                    Label(
                        "Logout",
                        systemImage: "arrow.up.forward.square"
                    )
                }
            )
            .foregroundColor(.red)
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Notifications Section

private extension SettingsScreen {
    
    /// The notifications section.
    var notificationsSection: some View {
        Section(
            header: Text("Notifications")
        ) {
            ForEach(
                LocalNotificationRequest
                    .Predefined
                    .allCases,
                id: \.self
            ) { predefinedLocationNotificationRequest in
                NavigationLink(
                    destination: LocalNotificationForm(
                        predefinedLocationNotificationRequest: predefinedLocationNotificationRequest
                    )
                ) {
                    Label {
                        Text(predefinedLocationNotificationRequest.localizedString)
                    } icon: {
                        predefinedLocationNotificationRequest
                            .icon
                            .imageScale(.small)
                            .foregroundColor(predefinedLocationNotificationRequest.tintColor)
                            .padding(8)
                            .background(predefinedLocationNotificationRequest.tintColor.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            Toggle(
                isOn: self.$recurringConsumptionsReminderService.isEnabled
            ) {
                HStack(spacing: 14) {
                    Image(
                        systemName: "arrow.clockwise.circle.fill"
                    )
                    .imageScale(.small)
                    .foregroundColor(.accentColor)
                    .padding(8)
                    .background(Color.accentColor.opacity(0.3))
                    .clipShape(Circle())
                    Text("Regular energy behaviour changes")
                }
                .multilineTextAlignment(.leading)
            }
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Privacy Section

private extension SettingsScreen {
    
    /// The privacy section.
    var privacySection: some View {
        Section(
            header: Text("Data privacy")
        ) {
            AsyncButton(
                alert: { result in
                    switch result {
                    case .success(let userDataFile):
                        return .init(
                            title: Text("Export Data"),
                            message: Text(
                                "Your data has been successfully downloaded. Do you want to export it?"
                            ),
                            primaryButton: .default(Text("Export")) {
                                self.export(userDataFile: userDataFile)
                            },
                            secondaryButton: .cancel()
                        )
                    case .failure:
                        return .init(
                            title: Text("Error"),
                            message: Text(
                                "An error occurred while trying to download your data."
                            )
                        )
                    }
                },
                action: {
                    try await self.firebase.functions.downloadUserData()
                },
                label: {
                    Label(
                        "Download my data",
                        systemImage: "square.and.arrow.down"
                    )
                }
            )
            AsyncButton(
                confirmationDialog: { action in
                    .init(
                        title: Text("Account deletion"),
                        message: Text(
                            "Are you sure you want to delete your account?"
                        ),
                        buttons: [
                            .destructive(
                                Text("Delete account"),
                                action: action
                            ),
                            .cancel()
                        ]
                    )
                },
                alert: { result in
                    guard case .failure(let error) = result else {
                        return nil
                    }
                    if (error as? AuthErrorCode)?.code == .requiresRecentLogin {
                        return .init(
                            title: Text("Recent login required"),
                            message: Text(
                                "Please logout and login again to delete your account."
                            )
                        )
                    } else {
                        return .init(
                            title: Text("Error"),
                            message: Text(
                                "An error occurred while trying to delete your account."
                            )
                        )
                    }
                },
                action: {
                    try await self.firebase.authentication.deleteAccount()
                },
                label: {
                    Label(
                        "Delete my account",
                        systemImage: "trash"
                    )
                }
            )
            .foregroundColor(.red)
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Support Section

private extension SettingsScreen {
    
    /// The support section.
    var supportSection: some View {
        Section(
            header: Text("Support")
        ) {
            Link(
                destination: .init(
                    string: "https://www.aurora-h2020.eu/aurora/ourapp/"
                )!
            ) {
                Label(
                    "About the App",
                    systemImage: "square.stack.3d.up.fill"
                )
            }
            Link(
                destination: {
                    let url = URL(string: "https://aurora-h2020.eu/app-support")!
                    guard let userAccountId = try? self.firebase.authentication.state.userAccount.uid else {
                        return url
                    }
                    guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                        return url
                    }
                    urlComponents.queryItems = [
                        .init(
                            name: "user_id",
                            value: userAccountId
                        ),
                        (
                            try? self.firebase.country?.get()
                        )?
                        .id
                        .flatMap { countryId in
                            .init(
                                name: "country_id",
                                value: countryId
                            )
                        }
                    ]
                    .compactMap { $0 }
                    return urlComponents.url ?? url
                }()
            ) {
                Label(
                    "Contact Support",
                    systemImage: "questionmark.circle.fill"
                )
            }
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Legal Section

private extension SettingsScreen {
    
    /// The legal section.
    var legalSection: some View {
        Section(
            header: Text("Legal information"),
            footer: HStack(spacing: 10) {
                Image("EU-Flag")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                Text(
                    "[This project](https://www.aurora-h2020.eu/) has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No. [101036418](https://cordis.europa.eu/project/id/101036418)."
                )
            }
            .padding(.vertical, 15)
            .listRowInsets(.init())
        ) {
            Link(
                destination: .init(
                    string: "https://www.aurora-h2020.eu/aurora/privacy-policy/"
                )!
            ) {
                Label(
                    "Imprint",
                    systemImage: "info.circle.fill"
                )
            }
            Link(
                destination: .init(
                    string: "https://www.aurora-h2020.eu/aurora/privacy-policy/"
                )!
            ) {
                Label(
                    "Privacy policy",
                    systemImage: "lock.fill"
                )
            }
            NavigationLink(
                destination: ThirdPartyDependencyList()
            ) {
                Label(
                    "Licenses",
                    systemImage: "doc.append.fill"
                )
            }
        }
        .headerProminence(.increased)
    }
    
}

// MARK: - Export User Data

private extension SettingsScreen {
    
    /// Export user data file
    /// - Parameter userDataFile: The user data file url which should be exported.
    func export(
        userDataFile: URL
    ) {
        // Verify root ViewController is available
        guard let rootViewController = UIApplication
            .shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)?
            .rootViewController else {
            // Otherwise return out of function
            return
        }
        // Initialize UIActivityViewController
        let activityViewController = UIActivityViewController(
            activityItems: [userDataFile],
            applicationActivities: nil
        )
        // Initialize source view
        let sourceView: UIView = rootViewController.view
        // Set source view
        activityViewController.popoverPresentationController?.sourceView = sourceView
        // Set source rect
        activityViewController.popoverPresentationController?.sourceRect = .init(
            x: sourceView.bounds.width / 2,
            y: sourceView.bounds.height / 2,
            width: 0,
            height: 0
        )
        // Present UIActivityViewController
        rootViewController
            .present(
                activityViewController,
                animated: true
            )
    }
    
}
