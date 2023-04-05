import SwiftUI

// MARK: - AuthenticationProviderButton+Style

extension AuthenticationProviderButton {
    
    /// An authentication provider button style.
    enum Style: String, Codable, Hashable, CaseIterable, Sendable {
        /// Apple.
        case apple = "Apple"
        /// Google.
        case google = "Google"
        /// email address.
        case mailAddress = "email"
    }
    
}

// MARK: - AuthenticationProviderButton+Style+icon

extension AuthenticationProviderButton.Style {
    
    var icon: Image {
        switch self {
        case .apple:
            return .init(
                systemName: "apple.logo"
            )
        case .google:
            return .init(
                "Google-Logo"
            )
        case .mailAddress:
            return .init(
                systemName: "envelope.fill"
            )
        }
    }
    
}

// MARK: - AuthenticationProviderButton+Style+foregroundColor

extension AuthenticationProviderButton.Style {
    
    func foregroundColor(
        colorScheme: ColorScheme
    ) -> Color {
        switch self {
        case .apple:
            if colorScheme == .dark {
                return .black
            } else {
                return .white
            }
        case .google:
            return .black.opacity(0.54)
        case .mailAddress:
            return .white
        }
    }
    
}

// MARK: - AuthenticationProviderButton+Style+tintColor

extension AuthenticationProviderButton.Style {
    
    func tintColor(
        colorScheme: ColorScheme
    ) -> Color {
        switch self {
        case .apple:
            if colorScheme == .dark {
                return .white
            } else {
                return .black
            }
        case .google:
            return .white
        case .mailAddress:
            return .blue
        }
    }
    
}

// MARK: - AuthenticationProviderButton+Style+borderColor

extension AuthenticationProviderButton.Style {
    
    func borderColor(
        colorScheme: ColorScheme
    ) -> Color? {
        switch self {
        case .apple:
            return nil
        case .google:
            if colorScheme != .dark {
                return self.foregroundColor(
                    colorScheme: colorScheme
                )
                .opacity(0.4)
            } else {
                return nil
            }
        case .mailAddress:
            return nil
        }
    }
    
}
