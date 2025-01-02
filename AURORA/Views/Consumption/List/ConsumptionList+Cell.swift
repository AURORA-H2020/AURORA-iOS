import SwiftUI

// MARK: - ConsumptionList+Cell

extension ConsumptionList {
    
    /// A ConsumptionList Cell
    struct Cell {
        
        /// The Consumption
        let consumption: Consumption
        
        /// An optional edit action.
        var editAction: (() -> Void)?
        
        /// Bool value if delete confirmation dialog is presented
        @State
        private var isDeleteConfirmationDialogPresented = false
        
        /// The locale.
        @Environment(\.locale)
        private var locale
        
        /// The Firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
    }
    
}

// MARK: - View

extension ConsumptionList.Cell: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack(spacing: 10) {
            self.consumption
                .icon
                .imageScale(.small)
                .frame(minWidth: 32, minHeight: 32)
                .foregroundColor(self.consumption.category.tintColor)
                .background(self.consumption.category.tintColor.opacity(0.3))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(self.consumption.localizedTitle)
                    .foregroundColor(.primary)
                Group {
                    switch self.consumption.category {
                    case .electricity:
                        if let electricityDateRange = self.consumption.electricity?.dateRange {
                            Text(
                                electricityDateRange,
                                format: .interval.day().month().year()
                            )
                        }
                    case .heating:
                        if let heatingDateRange = self.consumption.heating?.dateRange {
                            Text(
                                heatingDateRange,
                                format: .interval.day().month().year()
                            )
                        }
                    case .transportation:
                        if let transportation = self.consumption.transportation {
                            Text(
                                transportation.dateOfTravel.dateValue(),
                                format: .dateTime
                            )
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                if let description = self.consumption.description, !description.isEmpty {
                    Text(description)
                        .lineLimit(2)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
            VStack(alignment: .trailing) {
                Text(self.consumption.formatted(to: .init(locale: self.locale)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let carbonEmissions = self.consumption.carbonEmissions {
                    Text(
                        ConsumptionMeasurement(
                            value: carbonEmissions,
                            unit: .kilograms
                        )
                        .converted(to: .init(locale: self.locale))
                        .formatted(isCarbonEmissions: true)
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .multilineTextAlignment(.trailing)
        }
        .swipeActions(
            edge: .trailing
        ) {
            Button {
                self.isDeleteConfirmationDialogPresented = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            if let editAction = self.editAction {
                Button {
                    editAction()
                } label: {
                    Label("Edit", systemImage: "pencil.circle")
                }
                .tint(.accentColor)
            }
        }
        .confirmationDialog(
            "Delete Entry",
            isPresented: self.$isDeleteConfirmationDialogPresented,
            titleVisibility: .visible,
            actions: {
                Button(role: .destructive) {
                    try? self.firebase
                        .firestore
                        .delete(
                            self.consumption,
                            context: .current()
                        )
                } label: {
                    Text("Delete")
                }
                Button(role: .cancel) {   
                } label: {
                    Text("Cancel")
                }
            },
            message: {
                Text(
                    """
                    Are you sure you want to delete the entry?
                    Please note that it can take up to a minute for your summary to update.
                    """
                )
            }
        )
        .frame(minHeight: 38)
    }
    
}
