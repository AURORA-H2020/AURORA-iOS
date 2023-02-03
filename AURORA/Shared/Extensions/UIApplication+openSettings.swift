import UIKit

// MARK: - UIApplication+openSettings

extension UIApplication {
    
    /// Opens application settings.
    func openSettings() {
        URL(
            string: {
                if #available(iOS 16.0, *) {
                    return Self
                        .openNotificationSettingsURLString
                } else {
                    return Self
                        .openSettingsURLString
                }
            }()
        )
        .flatMap { url in
            self.open(url)
        }
    }
    
}
