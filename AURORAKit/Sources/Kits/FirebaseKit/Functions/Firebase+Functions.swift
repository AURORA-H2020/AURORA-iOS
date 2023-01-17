import FirebaseFunctions
import Foundation

// MARK: - Firebase+Functions

public extension Firebase {
    
    /// The Firebase Functions
    struct Functions {
        
        /// The Firebase Functions instance
        let functions: FirebaseFunctions.Functions
        
    }
    
}

// MARK: - Send Download Data Requests

public extension Firebase.Functions {
    
    /// Send download data request
    func downloadData() async throws {
        _ = try await self.functions
            .httpsCallable("download-data")
            .call()
    }
    
}
