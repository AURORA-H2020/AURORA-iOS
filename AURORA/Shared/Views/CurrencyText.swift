import SwiftUI

// MARK: - CurrencyText

/// A view that displays one or more lines of read-only currency formatted text.
struct CurrencyText<Value: BinaryFloatingPoint> {
    
    // MARK: Properties
    
    /// The value.
    private let value: Value
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
    // MARK: Initializer
    
    /// Creates a new instance of `CurrencyText`
    /// - Parameter value: The value.
    init(_ value: Value) {
        self.value = value
    }
    
}

// MARK: - View

extension CurrencyText: View {
    
    /// The content and behavior of the view.
    var body: Text {
        Text(
            self.value,
            format: .currency(
                code: ((try? self.firebase.country?.get()) ?? .europe).currencyCode
            )
        )
    }
    
}
