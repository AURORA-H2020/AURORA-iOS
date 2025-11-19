import SwiftUI

// MARK: - PhotovoltaicPlantInvestmentList+Cell

extension PhotovoltaicPlantInvestmentList {
    
    /// The Cell
    struct Cell {
        
        /// The photovoltaic plant investment.
        let photovoltaicPlantInvestment: PhotovoltaicPlantInvestment
        
        /// The presented photovoltaic plant investment form mode.
        @Binding
        var presentedPhotovoltaicPlantInvestmentFormMode: PhotovoltaicPlantInvestmentForm.Mode?
        
        /// Bool value if delete confirmation dialog is presented
        @State
        private var isDeleteConfirmationDialogPresented = false
        
        /// The Firebase instance
        @EnvironmentObject
        private var firebase: Firebase
        
    }
    
}

// MARK: - View

extension PhotovoltaicPlantInvestmentList.Cell: View {
    
    /// The content and behavior of the view.
    var body: some View {
        Button {
            self.presentedPhotovoltaicPlantInvestmentFormMode = .edit(self.photovoltaicPlantInvestment)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                if let investmentPrice = self.photovoltaicPlantInvestment.investmentPrice,
                   let country = try? self.firebase.country?.get() {
                    LabeledContent {
                        Text(
                            investmentPrice,
                            format: .currency(code: country.currencyCode)
                        )
                    } label: {
                        Text("Investment")
                            .bold()
                    }
                }
                if let investmentCapacity = self.photovoltaicPlantInvestment.investmentCapacity {
                    LabeledContent {
                        Text(
                            Measurement<UnitPower>(
                                value: investmentCapacity,
                                unit: .kilowatts
                            ),
                            format: .measurement(width: .abbreviated)
                        )
                    } label: {
                        Text("Capacity")
                            .bold()
                    }
                }
                LabeledContent {
                    Text(
                        self.photovoltaicPlantInvestment.share,
                        format: .number
                    )
                } label: {
                    Text("Share")
                        .bold()
                }
                LabeledContent {
                    Text(
                        self.photovoltaicPlantInvestment
                            .investmentDate
                            .dateValue()
                            .formatted(date: .numeric, time: .omitted)
                    )
                } label: {
                    Text("Investment Date")
                        .bold()
                }
                if let note = self.photovoltaicPlantInvestment.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }
            .multilineTextAlignment(.leading)
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
            Button {
                self.presentedPhotovoltaicPlantInvestmentFormMode = .edit(self.photovoltaicPlantInvestment)
            } label: {
                Label("Edit", systemImage: "pencil.circle")
            }
            .tint(.accentColor)
        }
        .confirmationDialog(
            "Delete Investment",
            isPresented: self.$isDeleteConfirmationDialogPresented,
            titleVisibility: .visible,
            actions: {
                Button(role: .destructive) {
                    try? self.firebase
                        .firestore
                        .delete(
                            self.photovoltaicPlantInvestment,
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
                Text("Are you sure you want to delete the investment?")
            }
        )
    }
    
}
