import SwiftUI

// MARK: - NumberTextField

/// The NumberTextField
struct NumberTextField<Value: Numeric & LosslessStringConvertible> {
    
    // MARK: Properties
    
    /// The title of the text view, describing its purpose
    private let title: LocalizedStringKey
    
    /// The underlying value to edit.
    @Binding
    private var value: Value?
    
    /// The previously converted value.
    @State
    private var previouslyConvertedValue: Value?
    
    /// The text to display and edit
    @State
    private var text: String
    
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
        self._previouslyConvertedValue = .init(
            initialValue: value.wrappedValue
        )
        self._text = .init(
            initialValue: value.wrappedValue?.localizedNumericString ?? .init()
        )
    }
    
}

// MARK: - View

extension NumberTextField: View {
    
    /// The content and behavior of the view.
    var body: some View {
        TextField(
            self.title,
            text: self.$text
        )
        .keyboardType(Value.self is any BinaryInteger.Type ? .numberPad : .decimalPad)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.never)
        .onChange(
            of: self.text,
            perform: self.textDidChange
        )
        .onChange(
            of: self.value,
            perform: self.valueDidChange
        )
    }
    
}

// MARK: - Text Did Change

private extension NumberTextField {
    
    /// Text did change
    /// - Parameter text: The new text
    func textDidChange(
        _ text: String
    ) {
        // Verify text is not empty
        guard !text.isEmpty else {
            // Otherwise clear value
            self.previouslyConvertedValue = nil
            self.value = nil
            // Return out of function
            return
        }
        // Declare bool if decimal separator is contained in the text
        lazy var foundDecimalSeparator = false
        // Filter text
        let text = text.filter { character in
            // Verify characer is not a number
            guard !character.isNumber else {
                // Otherwise accept number character
                return true
            }
            // Verify is not a binary integer
            guard !(Value.self is any BinaryInteger.Type) else {
                // Otherwise if it is a binary integer
                // do not include non number characters
                return false
            }
            // Verify character is a decimal separator
            // and a separator hasn't been previously found
            guard character == Locale.current.decimalSeparatorCharacter && !foundDecimalSeparator else {
                // Do not include character
                return false
            }
            // Toggle found decimal separator
            foundDecimalSeparator.toggle()
            // Include separator
            return true
        }
        // Set text
        self.text = text
        // Verify value can be initialized from text
        guard let newValue = Value(
            text.replacingOccurrences(
                of: String(Locale.current.decimalSeparatorCharacter),
                with: "."
            )
        ) else {
            // Otherwise return out of function
            return
        }
        // Update value
        self.previouslyConvertedValue = newValue
        self.value = newValue
    }
    
}

// MARK: - Value Did Change

private extension NumberTextField {
    
    /// Value did change.
    /// - Parameter value: The new value.
    func valueDidChange(
        _ value: Value?
    ) {
        // Verify previously converted value is not equal to the new value
        guard self.previouslyConvertedValue != value else {
            // Otherwise return out of function
            return
        }
        // Update value
        self.value = value
        // Update text
        self.text = value?.localizedNumericString ?? .init()
    }
    
}

// MARK: - LosslessStringConvertible+localizedString

private extension LosslessStringConvertible {
    
    /// A localized string.
    var localizedNumericString: String {
        String(self)
            .replacingOccurrences(
                of: ".",
                with: String(Locale.current.decimalSeparatorCharacter)
            )
    }
    
}

// MARK: - Locale+decimalSeparatorCharacter

private extension Locale {
    
    /// The decimal separator character of the locale.
    var decimalSeparatorCharacter: Character {
        self.decimalSeparator.flatMap(Character.init) ?? "."
    }
    
}
