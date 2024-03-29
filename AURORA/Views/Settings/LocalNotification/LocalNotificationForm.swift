import SwiftUI

// MARK: - LocalNotificationForm

/// The LocalNotificationForm
struct LocalNotificationForm {
    
    /// The Predefined LocalNotificationRequest
    let predefinedLocationNotificationRequest: LocalNotificationRequest.Predefined
    
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
                        action: UIApplication.shared.openSettings
                    )
                )
            } else {
                self.content
            }
        }
        .navigationTitle(self.predefinedLocationNotificationRequest.localizedString)
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
                .pendingNotificationRequest(self.predefinedLocationNotificationRequest.id)
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
                        id: self.predefinedLocationNotificationRequest.id,
                        content: self.predefinedLocationNotificationRequest.content,
                        trigger: .calendar(
                            dateMatching: matchingDateComponents,
                            repeats: true
                        )
                    )
                    do {
                        try await self.localNotificationCenter
                            .add(localNotificationRequest)
                    } catch {
                        return
                    }
                    self.nextTriggerDate = localNotificationRequest.nextTriggerDate
                }
            } else {
                self.localNotificationCenter
                    .removePendingNotificationRequest(self.predefinedLocationNotificationRequest.id)
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
            Section(
                footer: Group {
                    switch self.predefinedLocationNotificationRequest {
                    case .electricityBillReminder:
                        Text(
                            "We can remind you to enter your electricity consumption based on your bill. Just let us know when you expect the next one."
                        )
                    case .heatingBillReminder:
                        Text(
                            "We can remind you to enter your energy consumption based on your bill. Just let us know when you expect the next one."
                        )
                    case .mobilityReminder:
                        Text(
                            "We can remind you to regularly enter your transportation data. Just let us know how frequently you travel."
                        )
                    }
                }
                .multilineTextAlignment(.leading)
            ) {
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
                            Text(frequency.localizedString)
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
