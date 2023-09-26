import Foundation

// MARK: - User+HouseholdProfile

extension User {
    
    /// The household profile
    struct HouseholdProfile: Hashable {
        
        /// The type.
        let type: String
        
    }
    
}

// MARK: - Codable

extension User.HouseholdProfile: Codable {
    
    /// Creates a new instance of `User.HouseholdProfile`
    /// - Parameter decoder: The decoder.
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            type: try container.decode(String.self)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.type)
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension User.HouseholdProfile: ExpressibleByStringLiteral {
    
    /// Creates a new instance of `User.HouseholdProfile`
    /// - Parameter type: The type.
    init(
        stringLiteral type: String
    ) {
        self.init(type: type)
    }
    
}

// MARK: - Well Known Values

extension User.HouseholdProfile {
    
    /// Retired individuals
    static let retiredIndividuals: Self = "retiredIndividuals"
    
    /// Home-based workers/students
    static let homeBasedWorkersOrStudents: Self = "homeBasedWorkersOrStudents"
    
    /// Homemakers
    static let homemakers: Self = "homemakers"
    
    /// Workers/students outside the home
    static let workersOrStudentsOutsideTheHome: Self = "workersOrStudentsOutsideTheHome"
    
}

// MARK: - CaseIterable

extension User.HouseholdProfile: CaseIterable {
    
    /// A collection of all values of this type.
    static let allCases: [Self] = [
        .retiredIndividuals,
        .homeBasedWorkersOrStudents,
        .homemakers,
        .workersOrStudentsOutsideTheHome
    ]
    
}

// MARK: - Localized String

extension User.HouseholdProfile {
    
    /// A localized string.
    var localizedString: String {
        switch self {
        case .retiredIndividuals:
            return .init(localized: "Retired individuals")
        case .homeBasedWorkersOrStudents:
            return .init(localized: "Home-based workers/students")
        case .homemakers:
            return .init(localized: "Homemakers")
        case .workersOrStudentsOutsideTheHome:
            return .init(localized: "Workers/students outside the home")
        default:
            return .init(localized: "Unknown")
        }
    }
    
}
