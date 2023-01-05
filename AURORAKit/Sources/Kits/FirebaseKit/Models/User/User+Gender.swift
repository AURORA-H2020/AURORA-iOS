import Foundation

public extension User {
    
    enum Gender: String, Codable, Hashable, CaseIterable {
        case male
        case female
        case nonBinary
        case other
    }
    
}
