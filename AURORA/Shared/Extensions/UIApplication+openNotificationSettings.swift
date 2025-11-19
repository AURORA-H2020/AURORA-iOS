import UIKit

// MARK: - UIApplication+openNotificationSettings

extension UIApplication {
    
    /// Opens the notification settings.
    func openNotificationSettings() {
        URL(
            string: Self.openNotificationSettingsURLString
        )
        .flatMap { url in
            self.open(url)
        }
    }
    
}
