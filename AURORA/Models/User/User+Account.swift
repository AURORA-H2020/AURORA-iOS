import FirebaseAuth
import Foundation

// MARK: - User+Account

extension User {
    
    /// The User Account.
    /// Typealias representing an instance of  `FirebaseAuth.User`
    typealias Account = FirebaseAuth.User
    
}

// MARK: - User+Account+Identifiable

extension User.Account: @retroactive Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    public var id: String {
        self.uid
    }
    
}
