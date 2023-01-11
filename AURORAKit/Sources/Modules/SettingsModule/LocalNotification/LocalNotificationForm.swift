import LocalNotificationKit
import SwiftUI

// MARK: - LocalNotificationForm

/// The LocalNotificationForm
struct LocalNotificationForm {
    
    /// The LocalNotificationRequest Identifier
    let id: LocalNotificationRequest.ID
    
    private let localNotificationCenter: LocalNotificationCenter = .current
    
    @State
    private var isDraft = false
    
    @State
    private var frequency: Frequency?
    
    @State
    private var dateComponents = DateComponents()
    
    @State
    private var pendingNotificationRequest: UNNotificationRequest?
    
}

private extension LocalNotificationForm {
    
    enum Frequency: String, Codable, Hashable, CaseIterable {
        case weekly
        case monthly
        case yearly
        
        var localizedString: String {
            switch self {
            case .weekly:
                return "Every week"
            case .monthly:
                return "Every month"
            case .yearly:
                return "Every year"
            }
        }
    }
    
}

// MARK: - View

extension LocalNotificationForm: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                Toggle(
                    "Enabled",
                    isOn: .init(
                        get: {
                            self.isDraft || self.pendingNotificationRequest != nil
                        },
                        set: { isOn in
                            if isOn {
                                self.isDraft = true
                            } else {
                                self.isDraft = false
                                self.pendingNotificationRequest = nil
                                self.localNotificationCenter
                                    .removePendingNotificationRequests(
                                        identifiers: [self.id.rawValue]
                                    )
                            }
                        }
                    )
                )
            }
            if self.isDraft || self.pendingNotificationRequest != nil {
                Section {
                    Picker("Frequeny", selection: self.$frequency) {
                        ForEach(Frequency.allCases, id: \.self) { frequency in
                            Text(
                                verbatim: frequency.localizedString
                            )
                            .tag(frequency as Frequency?)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notification")
        .task {
            let pendingNotificationRequest = await self.localNotificationCenter
                .pendingNotificationRequests
                .first { $0.identifier == self.id.rawValue }
            if let dateComponents = (
                self.pendingNotificationRequest?.trigger as? UNCalendarNotificationTrigger
            )?.dateComponents {
                self.dateComponents = dateComponents
            }
            self.pendingNotificationRequest = pendingNotificationRequest
        }
    }
    
}
