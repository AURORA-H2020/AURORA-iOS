import Combine
import SwiftUI

// MARK: - NumberTextField

/// A TextField that only allows numeric input
public struct NumberTextField {
    
    /// The title of the text view, describing its purpose
    private let title: String
    
    /// The unit symbol.
    private let unitSymbol: String?
    
    /// The NumberFormatter.
    private let numberFormatter: NumberFormatter?
    
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
    ///   - title: The title of the text view, describing its purpose.
    ///   - number: A Binding to a double value.
    ///   - unitSymbol: The optional unit symbol. Default value `nil`
    ///   - numberFormatter: The optional NumberFormatter. Default value `nil`
    init(
        _ title: String,
        number: Binding<Double?>,
        unitSymbol: String? = nil,
        numberFormatter: NumberFormatter? = nil
    ) {
        self.title = title
        self.unitSymbol = unitSymbol
        self.numberFormatter = numberFormatter
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
    ///   - title: The title of the text view, describing its purpose.
    ///   - number: A Binding to an integer value.
    ///   - unitSymbol: The optional unit symbol. Default value `nil`
    ///   - numberFormatter: The optional NumberFormatter. Default value `nil`
    init(
        _ title: String,
        number: Binding<Int?>,
        unitSymbol: String? = nil,
        numberFormatter: NumberFormatter? = nil
    ) {
        self.title = title
        self.unitSymbol = unitSymbol
        self.numberFormatter = numberFormatter
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
        HStack {
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
            if let unitSymbol = self.unitSymbol {
                Text(
                    verbatim: unitSymbol
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
    }
    
}

// MARK: - Text did change

private extension NumberTextField {
    
    /// The decimal separator
    static let decimalSeparator = "."
    
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
                    of: Locale.current.decimalSeparator ?? Self.decimalSeparator,
                    with: Self.decimalSeparator
                )
                // Only allow numbers and dots
                .filter { $0.isNumber || String($0) == Self.decimalSeparator }
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
        text = {
            if let formattedText = self.numberFormatter?.string(from: .init(value: number)) {
                return formattedText
            } else {
                return text.replacingOccurrences(
                    of: Self.decimalSeparator,
                    with: Locale.current.decimalSeparator ?? Self.decimalSeparator
                )
            }
        }()
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
