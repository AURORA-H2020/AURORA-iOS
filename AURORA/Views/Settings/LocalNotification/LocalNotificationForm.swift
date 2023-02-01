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
    
    /// The next date at which the trigger conditions are met.
    @State
    private var nextTriggerDate: Date?
    
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
                        title: "Open Settings",
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
            let pendingNotificationRequest = await self.localNotificationCenter
                .pendingNotificationRequest(self.id)
            self.nextTriggerDate = pendingNotificationRequest?.nextTriggerDate
            self.matchingDateComponents = pendingNotificationRequest?
                .trigger?
                .matchingDateComponents
        }
        .onChange(
            of: self.matchingDateComponents
        ) { matchingDateComponents in
            if let matchingDateComponents = matchingDateComponents {
                Task {
                    let localNotificationRequest = LocalNotificationRequest(
                        id: self.id,
                        content: .inferred(by: self.id),
                        trigger: .calendar(
                            dateMatching: matchingDateComponents,
                            repeats: true
                        )
                    )
                    try await self.localNotificationCenter
                        .add(localNotificationRequest)
                    self.nextTriggerDate = localNotificationRequest.nextTriggerDate
                }
            } else {
                self.localNotificationCenter
                    .removePendingNotificationRequest(self.id)
                self.nextTriggerDate = nil
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
                                self.matchingDateComponents = .init(
                                    frequency: .monthly,
                                    time: (hour: 10, minute: 0)
                                )
                            } else {
                                self.matchingDateComponents = nil
                            }
                        }
                    )
                )
            }
            if let matchingDateComponents = self.matchingDateComponents {
                Section(
                    footer: Group {
                        if let nextTriggerDate = self.nextTriggerDate {
                            Text(
                                "The next notification will be sent on \(nextTriggerDate.formatted())"
                            )
                        }
                    }
                ) {
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
                            Text(frequency.rawValue.capitalized)
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
                                Text(weekdaySymbol)
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
                                Text(String(day))
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
                                    Text(monthSymbol)
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
