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
    
    /// The download user data bad response error
    struct DownloadUserDataBadResponseError: Error {
        /// Creates a new instance of `DownloadUserDataBadResponseError`
        public init() {}
    }
    
    /// Download user data and save it as a file to the cache directory.
    /// - Returns: The URL which points to a file in JSON format which contains the downloaded user data.
    func downloadUserData() async throws -> URL {
        // Try to initialize cache directory url
        let cacheDirectoryURL = try FileManager
            .default
            .url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
        // Call https callable cloud function
        let result = try await self.functions
            .httpsCallable("downloadUserData")
            .call()
        // Verify data is a dictionary
        guard let response = result.data as? [String: Any] else {
            // Otherwise throw an error
            throw DownloadUserDataBadResponseError()
        }
        // Try to serialize dictionary as data
        let userData = try JSONSerialization
            .data(
                withJSONObject: response,
                options: [
                    .prettyPrinted,
                    .sortedKeys,
                    .withoutEscapingSlashes
                ]
            )
        // Initialize user data file url
        let userDataFileURL = cacheDirectoryURL
            .appendingPathComponent(
                [
                    [
                        "AURORA",
                        "Export",
                        {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-MM-yyyy-HH-mm"
                            return dateFormatter.string(from: .init())
                        }()
                    ]
                    .joined(separator: "-"),
                    "json"
                ]
                .joined(separator: ".")
            )
        // Try to write user data to url
        try userData.write(to: userDataFileURL)
        // Return user data file url
        return userDataFileURL
    }
    
}
