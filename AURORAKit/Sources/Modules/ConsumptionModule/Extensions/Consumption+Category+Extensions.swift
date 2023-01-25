import FirebaseKit
import SwiftUI

// MARK: - Consumption+Category+localizedString

extension Consumption.Category {
    
    /// The localized string.
    var localizedString: String {
        switch self {
        case .electricity:
            return "Electricity"
        case .heating:
            return "Heating"
        case .transportation:
            return "Transportation"
        }
    }
    
}

// MARK: - Consumption+Category+icon

extension Consumption.Category {
    
    /// The icon.
    var icon: Image {
        .init(
            systemName: {
                switch self {
                case .electricity:
                    return "bolt"
                case .heating:
                    return "heater.vertical"
                case .transportation:
                    return "car"
                }
            }()
        )
    }
    
}

// MARK: - Consumption+Category+tintColor

extension Consumption.Category {
    
    /// The tint color.
    var tintColor: Color {
        switch self {
        case .electricity:
            return .yellow
        case .heating:
            return .red
        case .transportation:
            return .blue
        }
    }
    
}
