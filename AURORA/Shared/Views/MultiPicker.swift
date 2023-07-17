import SwiftUI

// MARK: - MultiPicker

/// A control for selecting multiple values from a set of options.
struct MultiPicker<Options: RandomAccessCollection, Label: View, Content: View, RowContent: View> where Options.Element: Hashable {
    
    // MARK: Typealias
    
    /// A single option.
    typealias Option = Options.Element
    
    /// The selection of options.
    typealias Selection = Set<Option>
    
    // MARK: Properties
    
    /// The options to select from.
    private let options: Options
    
    /// The selection.
    @Binding
    private var selection: Selection
    
    /// The label.
    private let label: Label
    
    /// A closure providing the content for the current selection.
    private let content: (Selection) -> Content
    
    /// A closure that creates the view for a single row of the list.
    private let rowContent: (Option) -> RowContent
    
    // MARK: Initializer
    
    /// Creates a new instance of `MultiPicker`
    /// - Parameters:
    ///   - options: The options to select from.
    ///   - selection: A binding to a property that determines the currently-selected options.
    ///   - label: A closure providing a view that describes the purpose of selecting an option.
    ///   - content: A closure providing a view that describes the selection.
    ///   - rowContent: A closure providing a view for a single row of the list.
    init(
        _ options: Options,
        selection: Binding<Selection>,
        @ViewBuilder
        label: () -> Label,
        @ViewBuilder
        content: @escaping (Selection) -> Content,
        @ViewBuilder
        rowContent: @escaping (Option) -> RowContent
    ) {
        self.options = options
        self._selection = selection
        self.content = content
        self.label = label()
        self.rowContent = rowContent
    }
    
}

// MARK: - Convenience Initializers

extension MultiPicker {
    
    /// Creates a new instance of `MultiPicker`
    /// - Parameters:
    ///   - titleKey: A localized string key that describes the purpose of selecting an option.
    ///   - options: The options to select from.
    ///   - selection: A binding to a property that determines the currently-selected options.
    ///   - content: A closure providing a view that describes the selection.
    ///   - rowContent: A closure providing a view for a single row of the list.
    init(
        _ titleKey: LocalizedStringKey,
        _ options: Options,
        selection: Binding<Selection>,
        @ViewBuilder
        content: @escaping (Selection) -> Content,
        @ViewBuilder
        rowContent: @escaping (Option) -> RowContent
    ) where Label == Text {
        self.init(
            options,
            selection: selection,
            label: {
                Text(titleKey)
            },
            content: content,
            rowContent: rowContent
        )
    }
    
    /// Creates a new instance of `MultiPicker`
    /// - Parameters:
    ///   - titleKey: A localized string key that describes the purpose of selecting an option.
    ///   - options: The options to select from.
    ///   - selection: A binding to a property that determines the currently-selected options.
    ///   - textRepresentation: A closure providing the text representation of an option.
    init(
        _ titleKey: LocalizedStringKey,
        _ options: Options,
        selection: Binding<Selection>,
        textRepresentation: @escaping (Option) -> String
    ) where Options.Element: Comparable, Label == Text, Content == Text, RowContent == Text {
        self.init(
            options,
            selection: selection,
            label: {
                Text(titleKey)
            },
            content: { selection in
                Text(
                    selection
                        .sorted()
                        .map(textRepresentation)
                        .formatted(.list(type: .and))
                )
                .font(.callout)
                .foregroundColor(.secondary)
            },
            rowContent: { element in
                Text(textRepresentation(element))
            }
        )
    }
    
}

// MARK: - View

extension MultiPicker: View {
    
    /// The content and behavior of the view.
    var body: some View {
        NavigationLink(
            destination: List(
                self.options,
                id: \.self,
                selection: self.$selection,
                rowContent: self.rowContent
            )
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Select")
        ) {
            HStack {
                self.label
                    .multilineTextAlignment(.leading)
                Spacer()
                self.content(self.selection)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
}
