import SwiftUI

// MARK: - ConsumptionView

/// The ConsumptionView
struct ConsumptionView {
    
    /// The Consumption
    let consumption: Consumption
    
    /// Bool value if delete confirmation dialog is presented
    @State
    private var isDeleteConfirmationDialogPresented = false
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
}

// MARK: - View

extension ConsumptionView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            
        }
        .navigationTitle(self.consumption.category.localizedString)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    self.isDeleteConfirmationDialogPresented = true
                } label: {
                    Label(
                        "Delete",
                        systemImage: "trash"
                    )
                    .foregroundColor(.red)
                }
            }
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
                    Text(verbatim: "Delete")
                }
                Button(role: .cancel) {
                } label: {
                    Text(verbatim: "Cancel")
                }
            },
            message: {
                Text(verbatim: "Are you sure you want to delete the entry?")
            }
        )
    }
    
}
