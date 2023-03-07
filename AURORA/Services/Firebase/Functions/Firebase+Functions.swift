import FirebaseFunctions
import Foundation

// MARK: - Firebase+Functions

extension Firebase {
    
    /// The Firebase Functions
    struct Functions {
        
        /// The Firebase instance
        let firebase: Firebase
        
    }
    
}

// MARK: - Send Download Data Requests

extension Firebase.Functions {
    
    /// Download user data and save it as a file to the cache directory.
    /// - Returns: The URL which points to a file in JSON format which contains the downloaded user data.
    func downloadUserData() async throws -> URL {
        // Record any error which occurs when trying to sign in
        try await self.firebase.crashlytics.recordError {
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
            let result = try await self.firebase
                .firebaseFunctions
                .httpsCallable("downloadUserData")
                .call()
            // Verify data is a dictionary
            guard let response = result.data as? [String: Any] else {
                // Otherwise throw an error
                throw DecodingError
                    .dataCorrupted(
                        .init(
                            codingPath: .init(),
                            debugDescription: "Bad Response"
                        )
                    )
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
    
}

// MARK: - Calculate Photovoltaic Investment

extension Firebase.Functions {
    
    /// A photovoltaic investment result
    struct PhotovoltaicInvestmentResult: Codable, Hashable {
        
        /// The produced energy
        let producedEnergy: Double
        
        /// The carbon emissions savings
        let carbonEmissionsSavings: Double
        
    }
    
    /// Calculate Photovoltaic Investment
    /// - Parameter amount: The amount to invest
    func calculatePhotovoltaicInvestment(
        amount: Double
    ) async throws -> PhotovoltaicInvestmentResult {
        // Call function with amount
        let result = try await self.firebase
            .firebaseFunctions
            .httpsCallable("calculatePhotovoltaicInvestment")
            .call(amount)
        // Try to decode result
        return try JSONDecoder()
            .decode(
                PhotovoltaicInvestmentResult.self,
                from: {
                    // Verify data is a dictionary
                    guard let response = result.data as? [String: Any] else {
                        // Otherwise throw an error
                        throw DecodingError
                            .dataCorrupted(
                                .init(
                                    codingPath: .init(),
                                    debugDescription: "Bad Response"
                                )
                            )
                    }
                    // Try to serialize dictionary as data
                    return try JSONSerialization
                        .data(
                            withJSONObject: response,
                            options: .init()
                        )
                }()
            )
    }
    
}
