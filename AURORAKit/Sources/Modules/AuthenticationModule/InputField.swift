import SwiftUI

// MARK: - InputField

/// An InputField
public struct InputField {
    
    // MARK: Properties
    
    /// The Configuration
    private let configuration: Configuration
    
    /// Bool value if password should be shown
    @State
    private var showPassword = false
    
    /// The ColorScheme
    @Environment(\.colorScheme)
    private var colorScheme
    
    // MARK: Initializer
    
    /// Creates a new instance of `InputField`
    /// - Parameter configuration: The Configuration
    public init(
        _ configuration: Configuration
    ) {
        self.configuration = configuration
    }
    
}

// MARK: - InputField+Configuration

public extension InputField {
    
    /// An InputField Configuration
    enum Configuration {
        /// E-Mail
        case email(
            _ text: Binding<String>
        )
        /// Text
        case text(
            _ text: Binding<String>,
            systemImage: String,
            label: String,
            textContentType: UITextContentType
        )
        /// Password
        case password(
            _ text: Binding<String>,
            label: String? = nil,
            customTextContentType: UITextContentType? = nil
        )
        /// Date
        case date(
            _ date: Binding<Date>,
            label: String,
            displayedComponents: DatePicker<Text>.Components = .date,
            acceptableRange: PartialRangeThrough<Date>? = nil
        )
    }
    
}

// MARK: - View

extension InputField: View {
    
    /// The content and behavior of the view
    public var body: some View {
        HStack {
            switch self.configuration {
            case .email(let text):
                Image(
                    systemName: "envelope.circle.fill"
                )
                .font(.system(size: 20))
                .foregroundColor(
                    !text.wrappedValue.isEmpty ? .accentColor : .secondary
                )
                TextField(
                    "E-Mail",
                    text: text
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            case .text(let text, let systemImage, let label, let textContentType):
                Image(
                    systemName: systemImage
                )
                .font(.system(size: 20))
                .foregroundColor(
                    !text.wrappedValue.isEmpty ? .accentColor : .secondary
                )
                TextField(
                    label,
                    text: text
                )
                .textContentType(textContentType)
            case .password(let text, let label, let customTextContentType):
                Image(
                    systemName: "lock.circle.fill"
                )
                .font(.system(size: 20))
                .foregroundColor(
                    !text.wrappedValue.isEmpty ? .accentColor : .secondary
                )
                if self.showPassword {
                    TextField(
                        label ?? "Password",
                        text: text
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(customTextContentType ?? .password)
                } else {
                    SecureField(
                        label ?? "Password",
                        text: text
                    )
                    .textContentType(customTextContentType ?? .password)
                }
                if !text.wrappedValue.isEmpty {
                    Button(
                        action: {
                            Self.endEditing()
                            self.showPassword.toggle()
                        },
                        label: {
                            Image(
                                systemName: self.showPassword ? "eye.slash" : "eye"
                            )
                        }
                    )
                    .foregroundColor(.secondary)
                }
            case .date(let date, let label, let displayedComponents, let acceptableRange):
                Image(
                    systemName: "calendar.circle.fill"
                )
                .font(.system(size: 20))
                .foregroundColor(.accentColor)
                if let acceptableRange = acceptableRange {
                    DatePicker(
                        label,
                        selection: date,
                        in: acceptableRange,
                        displayedComponents: displayedComponents
                    )
                } else {
                    DatePicker(
                        label,
                        selection: date,
                        displayedComponents: displayedComponents
                    )
                }
            }
        }
        .padding(
            .init(
                top: 15,
                leading: 12,
                bottom: 15,
                trailing: 12
            )
        )
        .background(
            RoundedRectangle(
                cornerRadius: 10
            )
            .foregroundColor(Color(.systemGray6))
        )
    }
    
}

// MARK: - End Editing

public extension InputField {
    
    /// Causes the view (or one of its embedded text fields) to resign the first responder status.
    /// - Parameters:
    ///   - application: The UIApplication. Default value `.shared`
    ///   - force: Specify true to force the first responder to resign,
    ///   regardless of whether it wants to do so. Default value `true`
    static func endEditing(
        application: UIApplication = .shared,
        force: Bool = true
    ) {
        application
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first(where: \.isKeyWindow)?
            .endEditing(force)
    }
    
}
