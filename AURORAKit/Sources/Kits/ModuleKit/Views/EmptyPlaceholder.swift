import SwiftUI

// MARK: - EmptyPlaceholder

/// An EmptyPlaceholder
public struct EmptyPlaceholder {
    
    // MARK: Properties
    
    /// The optional system image
    private let systemImage: String?
    
    /// The optional system image color
    private let systemImageColor: Color?
    
    /// The title
    private let title: String
    
    /// The optional subtitle
    private let subtitle: String?
    
    /// The optional primary action
    private let primaryAction: Action?
    
    /// The optional secondary action
    private let secondaryAction: Action?
    
    // MARK: Initializer
    
    /// Creates a new instance of `EmptyPlaceholder`
    /// - Parameters:
    ///   - systemImage: The optional system image. Default value `nil`
    ///   - systemImageColor: The optional system image color. Default value `nil`
    ///   - title: The title
    ///   - subtitle: The optional subtitle. Default value `nil`
    ///   - primaryAction: The optional primary action. Default value `nil`
    ///   - secondaryAction: The optional secondary action. Default value `nil`
    public init(
        systemImage: String? = nil,
        systemImageColor: Color? = nil,
        title: String,
        subtitle: String? = nil,
        primaryAction: Action? = nil,
        secondaryAction: Action? = nil
    ) {
        self.systemImage = systemImage
        self.systemImageColor = systemImageColor
        self.title = title
        self.subtitle = subtitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
}

// MARK: - Action

public extension EmptyPlaceholder {
    
    /// An EmptyPlaceholder Action
    struct Action {
        
        // MARK: Properties
        
        /// The action title
        let title: String
        
        /// The action that should be executed
        let action: () -> Void
        
        // MARK: Initializer
        
        /// Creates a new instance of `EmptyPlaceholder.Action`
        /// - Parameters:
        ///   - title: The action title
        ///   - action: The action that should be executed
        public init(
            title: String,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.action = action
        }
        
    }
    
}

// MARK: - View

extension EmptyPlaceholder: View {
    
    /// The content and behavior of the view
    public var body: some View {
        VStack(spacing: 24) {
            if let systemImage = self.systemImage {
                Image(
                    systemName: systemImage
                )
                .foregroundColor(self.systemImageColor ?? .gray)
                .font(.system(size: 75, weight: .thin))
            }
            VStack(spacing: 5) {
                Text(
                    verbatim: self.title
                )
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                if let subtitle = self.subtitle {
                    Text(
                        verbatim: subtitle
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)
            VStack(spacing: 18) {
                if let primaryAction = self.primaryAction {
                    Button(
                        action: primaryAction.action
                    ) {
                        Text(
                            verbatim: primaryAction.title
                        )
                        .font(.body.bold())
                        .padding(.horizontal, 30)
                        .padding(.vertical, 3)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                    .buttonBorderShape(.capsule)
                }
                if let secondaryAction = self.secondaryAction {
                    Button(
                        action: secondaryAction.action
                    ) {
                        Text(
                            verbatim: secondaryAction.title
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .align(.centerHorizontal)
    }
    
}
