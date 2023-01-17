import LocalNotificationKit
import ModuleKit
import SwiftUI

// MARK: - LocalNotificationForm

/// The LocalNotificationForm
struct LocalNotificationForm {
    
    /// The LocalNotificationRequest Identifier
    let id: LocalNotificationRequest.ID
    
    /// The LocalNotificationCenter
    var localNotificationCenter: LocalNotificationCenter = .current
    
    /// The UNAuthorizationStatus.
    @State
    private var authorizationStatus: UNAuthorizationStatus?
    
    /// The MatchingDateComponents.
    @State
    private var matchingDateComponents: LocalNotificationRequest.Trigger.MatchingDateComponents?
    
}

// MARK: - View

extension LocalNotificationForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Group {
            if self.authorizationStatus == .denied {
                EmptyPlaceholder(
                    systemImage: "app.badge",
                    title: "Notifications",
                    subtitle: "Please enable notifications for the AURORA app in the settings of your device.",
                    primaryAction: .init(
                        title: "Allow",
                        action: {
                            URL(
                                string: {
                                    if #available(iOS 16.0, *) {
                                        return UIApplication
                                            .openNotificationSettingsURLString
                                    } else {
                                        return UIApplication
                                            .openSettingsURLString
                                    }
                                }()
                            )
                            .flatMap { url in
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                )
            } else {
                self.content
            }
        }
        .navigationTitle("Notification")
        .task {
            self.authorizationStatus = await self.localNotificationCenter.authorizationStatus
        }
        .onReceive(
            NotificationCenter
                .default
                .publisher(
                    for: UIApplication.didBecomeActiveNotification
                )
        ) { _ in
            Task {
                self.authorizationStatus = await self.localNotificationCenter.authorizationStatus
            }
        }
        .task {
            self.matchingDateComponents = await self.localNotificationCenter
                .pendingNotificationRequest(self.id)?
                .trigger?
                .matchingDateComponents
        }
        .onChange(
            of: self.matchingDateComponents
        ) { matchingDateComponents in
            if let matchingDateComponents = matchingDateComponents {
                Task {
                    try await self.localNotificationCenter.add(
                        .init(
                            id: self.id,
                            content: .inferred(by: self.id),
                            trigger: .calendar(
                                dateMatching: matchingDateComponents,
                                repeats: true
                            )
                        )
                    )
                }
            } else {
                self.localNotificationCenter
                    .removePendingNotificationRequest(self.id)
            }
        }
    }
    
}

// MARK: - Content

private extension LocalNotificationForm {
    
    /// The content view.
    var content: some View {
        List {
            Section {
                Toggle(
                    "Enabled",
                    isOn: .init(
                        get: {
                            self.matchingDateComponents != nil
                        },
                        set: { isOn in
                            if isOn {
                                self.matchingDateComponents = .init()
                            } else {
                                self.matchingDateComponents = nil
                            }
                        }
                    )
                )
            }
            if let matchingDateComponents = self.matchingDateComponents {
                Section {
                    Picker(
                        "Frequency",
                        selection: .init(
                            get: {
                                matchingDateComponents.frequency
                            },
                            set: { frequency in
                                self.matchingDateComponents?.frequency = frequency
                            }
                        )
                    ) {
                        ForEach(
                            LocalNotificationRequest
                                .Trigger
                                .MatchingDateComponents
                                .Frequency
                                .allCases,
                            id: \.self
                        ) { frequency in
                            Text(
                                verbatim: frequency.rawValue.capitalized
                            )
                            .tag(frequency)
                        }
                    }
                    switch matchingDateComponents.frequency {
                    case .daily:
                        EmptyView()
                    case .weekly:
                        Picker(
                            "Weekday",
                            selection: .init(
                                get: {
                                    matchingDateComponents.weekday
                                },
                                set: { weekday in
                                    self.matchingDateComponents?.weekday = weekday
                                }
                            )
                        ) {
                            ForEach(
                                Array(
                                    LocalNotificationRequest
                                        .Trigger
                                        .MatchingDateComponents
                                        .weekdaySymbols
                                        .enumerated()
                                ),
                                id: \.offset
                            ) { index, weekdaySymbol in
                                Text(
                                    verbatim: weekdaySymbol
                                )
                                .tag(index as Int?)
                            }
                        }
                    default:
                        Picker(
                            "Day",
                            selection: .init(
                                get: {
                                    matchingDateComponents.day
                                },
                                set: { day in
                                    self.matchingDateComponents?.day = day
                                }
                            )
                        ) {
                            ForEach(
                                matchingDateComponents.days,
                                id: \.self
                            ) { day in
                                Text(
                                    verbatim: .init(day)
                                )
                                .tag(day as Int?)
                            }
                        }
                        if matchingDateComponents.frequency == .yearly {
                            Picker(
                                "Month",
                                selection: .init(
                                    get: {
                                        matchingDateComponents.month
                                    },
                                    set: { month in
                                        self.matchingDateComponents?.month = month
                                    }
                                )
                            ) {
                                ForEach(
                                    Array(
                                        LocalNotificationRequest
                                            .Trigger
                                            .MatchingDateComponents
                                            .monthSymbols
                                            .enumerated()
                                    ),
                                    id: \.offset
                                ) { index, monthSymbol in
                                    Text(
                                        verbatim: monthSymbol
                                    )
                                    .tag(index as Int?)
                                }
                            }
                        }
                    }
                    DatePicker(
                        "Time",
                        selection: .init(
                            get: {
                                matchingDateComponents.time ?? .init()
                            },
                            set: { time in
                                self.matchingDateComponents?.time = time
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
    }
    
}
