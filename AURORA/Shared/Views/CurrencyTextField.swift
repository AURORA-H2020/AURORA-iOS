import SwiftUI

// MARK: - CurrencyTextField

/// The CurrencyTextField
struct CurrencyTextField<Value: Numeric & LosslessStringConvertible> {
    
    // MARK: Properties
    
    /// The title of the text view, describing its purpose
    private let title: LocalizedStringKey
    
    /// The underlying value to edit.
    @Binding
    private var value: Value?
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `NumberTextField`
    /// - Parameters:
    ///   - title: The title of the text view, describing its purpose
    ///   - value: The underlying value to edit.
    init(
        _ title: LocalizedStringKey,
        value: Binding<Value?>
    ) {
        self.title = title
        self._value = value
    }
    
}

// MARK: - View

extension CurrencyTextField: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack {
            NumberTextField(
                self.title,
                value: self.$value
            )
            Text(
                verbatim: ((try? self.firebase.country?.get()) ?? .europe).localizedCurrencySymbol
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }
    
}
