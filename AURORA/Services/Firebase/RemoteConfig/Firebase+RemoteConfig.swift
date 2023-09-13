import FirebaseRemoteConfig
import Foundation

// MARK: - Firebase+RemoteConfig

extension Firebase {
    
    /// The Firebase RemoteConfig
    struct RemoteConfig {
        
        /// The Firebase RemoteConfig instance.
        let remoteConfig: FirebaseRemoteConfig.RemoteConfig
        
    }
    
}

// MARK: - Latest Legal Documents Version

extension Firebase.RemoteConfig {
    
    /// The latest legal document version key.
    static let latestLegalDocumentsVersionKey = "latestLegalDocumentsVersion"
    
    /// The latest legal documents version
    var latestLegalDocumentsVersion: Int {
        self.remoteConfig[Self.latestLegalDocumentsVersionKey].numberValue.intValue
    }
    
}
