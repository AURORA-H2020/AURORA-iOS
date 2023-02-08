import SwiftUI

// MARK: - ConsumptionList+Cell

extension ConsumptionList {
    
    /// A ConsumptionList Cell
    struct Cell {
        
        /// The Consumption
        let consumption: Consumption
        
        /// Bool value if delete confirmation dialog is presented
        @State
        private var isDeleteConfirmationDialogPresented = false
        
        /// The Firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
    }
    
}

// MARK: - View

extension ConsumptionList.Cell: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack {
            self.consumption
                .category
                .icon
                .imageScale(.small)
                .foregroundColor(self.consumption.category.tintColor)
                .padding(8)
                .background(self.consumption.category.tintColor.opacity(0.3))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(self.consumption.category.rawValue.capitalized)
                    .foregroundColor(.primary)
                if let createdAt = self.consumption.createdAt?.dateValue() {
                    Text(createdAt.formatted(date: .numeric, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
            VStack(alignment: .trailing) {
                Text(self.consumption.formattedValue)
                    .foregroundColor(.secondary)
                if let formattedCarbonEmissions = self.consumption.formattedCarbonEmissions {
                    Text(formattedCarbonEmissions)
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
        }
        .confirmationDialog(
            "Delete Entry",
            isPresented: self.$isDeleteConfirmationDialogPresented,
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
                Text("Are you sure you want to delete the entry?")
            }
        )
    }
    
}
