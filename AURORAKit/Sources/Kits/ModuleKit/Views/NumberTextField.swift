import Combine
import SwiftUI

// MARK: - NumberTextField

/// A TextField that only allows numeric input
public struct NumberTextField {
    
    /// The title of the text view, describing its purpose
    private let title: String
    
    /// Bool value if number is a floating point value
    private let isFloatingPoint: Bool
    
    /// The number
    @Binding
    private var number: Double?
    
    /// The number text representation
    @State
    private var text: String
    
}

// MARK: - Initializer with Double Binding

public extension NumberTextField {
    
    /// Creates a new instance of `NumberTextField`
    /// - Parameters:
    ///   - title: The title of the text view, describing its purpose
    ///   - number: The number
    init(
        _ title: String,
        number: Binding<Double?>
    ) {
        self.title = title
        self.isFloatingPoint = true
        self._number = number
        self._text = .init(
            initialValue: number.wrappedValue.flatMap { String($0) } ?? .init()
        )
    }
    
}

// MARK: - Initializer with Integer Binding

public extension NumberTextField {
    
    /// Creates a new instance of `NumberTextField`
    /// - Parameters:
    ///   - title: The title of the text view, describing its purpose
    ///   - number: The number
    init(
        _ title: String,
        number: Binding<Int?>
    ) {
        self.title = title
        self.isFloatingPoint = false
        self._number = .init(
            get: {
                number.wrappedValue.flatMap(Double.init)
            },
            set: { newValue in
                number.wrappedValue = newValue.flatMap(Int.init)
            }
        )
        self._text = .init(
            initialValue: number.wrappedValue.flatMap(String.init) ?? .init()
        )
    }
    
}

// MARK: - View

extension NumberTextField: View {
    
    /// The content and behavior of the view
    public var body: some View {
        TextField(
            self.title,
            text: self.$text
        )
        .keyboardType(self.isFloatingPoint ? .decimalPad : .numberPad)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .onReceive(
            Just(self.text),
            perform: self.textDidChange
        )
        .onChange(of: self.number) { number in
            // Verify number is set to nil
            guard number == nil else {
                // Otherwise return out of function
                return
            }
            // Clear text
            self.text = .init()
        }
    }
    
}

// MARK: - Text did change

private extension NumberTextField {
    
    /// Text did change
    /// - Parameter text: The new text
    func textDidChange(
        _ text: String
    ) {
        // Initialize mutable text
        var text = text
        // Check if is floating point
        if self.isFloatingPoint {
            // Sanitize text
            text = text
                // Replace semicolon with dot
                .replacingOccurrences(
                    of: Locale.current.decimalSeparator ?? ".",
                    with: "."
                )
                // Only allow numbers and dots
                .filter { $0.isNumber || $0 == "." }
        } else {
            // Sanitize text
            text = text
                // Only allow numbers
                .filter(\.isNumber)
        }
        // Verify text is not empty and a Double can be initialized from text
        guard !text.isEmpty, let number = Double(text) else {
            // Otherwise perform transaction
            return withTransaction(.init()) {
                // Check if a number is available
                if self.number != nil {
                    // Clear number
                    self.number = nil
                }
                // Check if text is not empty
                if !self.text.isEmpty {
                    // Clear text
                    self.text = .init()
                }
            }
        }
        // Reformat text
        text = text.replacingOccurrences(
            of: ".",
            with: Locale.current.decimalSeparator ?? "."
        )
        // Verify number has changed
        guard number != self.number else {
            // Set text
            self.text = text
            // Return out of function
            return
        }
        // Perform transaction
        withTransaction(.init()) {
            // Set text
            self.text = text
            // Set number
            self.number = number
        }
    }
    
}
