import SwiftUI

// MARK: - RecurringConsumptionList+Cell

extension RecurringConsumptionList {
    
    /// The Cell
    struct Cell {
        
        /// The recurring consumption.
        let recurringConsumption: RecurringConsumption
        
        /// Bool value if delete confirmation dialog is presented
        @State
        private var isDeleteConfirmationDialogPresented = false
        
        /// The Firebase instance.
        @EnvironmentObject
        private var firebase: Firebase
        
    }
    
}

// MARK: - View

extension RecurringConsumptionList.Cell: View {
    
    /// The content and behavior of the view.
    var body: some View {
        HStack(spacing: 10) {
            self.recurringConsumption
                .category
                .icon
                .imageScale(.small)
                .frame(minWidth: 32, minHeight: 32)
                .foregroundColor(self.recurringConsumption.category.tintColor)
                .background(self.recurringConsumption.category.tintColor.opacity(0.3))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(self.recurringConsumption.category.localizedString)
                    .foregroundColor(.primary)
                Text(self.recurringConsumption.frequency.unit.localizedString)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(self.recurringConsumption.isEnabled ? "Enabled" : "Disabled")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .opacity(self.recurringConsumption.isEnabled ? 1 : 0.5)
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
            titleVisibility: .visible,
            actions: {
                Button(role: .destructive) {
                    try? self.firebase
                        .firestore
                        .delete(
                            self.recurringConsumption,
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
