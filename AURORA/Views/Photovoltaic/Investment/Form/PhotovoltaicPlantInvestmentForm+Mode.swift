import Foundation

// MARK: - PhotovoltaicPlantInvestmentForm+Mode

extension PhotovoltaicPlantInvestmentForm {
    
    /// A photovoltaic plant investment form mode
    enum Mode: Hashable {
        /// Create
        case create(PhotovoltaicPlant)
        /// Edit
        case edit(PhotovoltaicPlantInvestment, PhotovoltaicPlant? = nil)
    }
    
}

// MARK: - Identifiable

extension PhotovoltaicPlantInvestmentForm.Mode: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    var id: String {
        switch self {
        case .create(let photovoltaicPlant):
            return [
                "create",
                photovoltaicPlant.id
            ]
            .compactMap { $0 }
            .joined(separator: "-")
        case .edit(let investement, _):
            return [
                "edit",
                investement.id
            ]
            .compactMap { $0 }
            .joined(separator: "-")
        }
    }
    
}

// MARK: - PhotovoltaicPlant

extension PhotovoltaicPlantInvestmentForm.Mode {
    
    /// The photovoltaic plant, if available.
    var photovoltaicPlant: PhotovoltaicPlant? {
        switch self {
        case .create(let photovoltaicPlant):
            return photovoltaicPlant
        case .edit(_, let photovoltaicPlant):
            return photovoltaicPlant
        }
    }
    
}

// MARK: - Is Create

extension PhotovoltaicPlantInvestmentForm.Mode {
    
    /// Bool value if mode is set to `create`
    var isCreate: Bool {
        if case .create = self {
            return true
        } else {
            return false
        }
    }
    
}
