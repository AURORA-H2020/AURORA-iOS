import SwiftUI

// MARK: - MeasurementTextField

/// The MeasurementTextField
struct MeasurementTextField<Value: Numeric & LosslessStringConvertible, Unit: View> {
    
    // MARK: Properties
    
    /// The title of the text view, describing its purpose
    private let title: LocalizedStringKey
    
    /// The underlying value to edit.
    @Binding
    private var value: Value?
    
    /// The unit.
    private let unit: Unit
    
    // MARK: Initializer
    
    /// Creates a new instance of `NumberTextField`
    /// - Parameters:
    ///   - title: The title of the text view, describing its purpose
    ///   - value: The underlying value to edit.
    init(
        _ title: LocalizedStringKey,
        value: Binding<Value?>,
        @ViewBuilder
        unit: () -> Unit
    ) {
        self.title = title
        self._value = value
        self.unit = unit()
    }
    
}

// MARK: - View

extension MeasurementTextField: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack {
            NumberTextField(
                self.title,
                value: self.$value
            )
            self.unit
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
}
