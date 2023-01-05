import FirebaseFirestoreSwift
import Foundation

public struct User: Codable, Hashable, Identifiable {
    
    @DocumentID
    public var id: String?
    
}
