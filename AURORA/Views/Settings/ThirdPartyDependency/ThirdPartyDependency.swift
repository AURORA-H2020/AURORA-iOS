import Foundation

// MARK: - ThirdPartyDependency

/// A ThirdPartyDependency
struct ThirdPartyDependency: Codable, Hashable {
    
    /// The author of the dependency
    let author: String
    
    /// The name of the dependency
    let name: String
    
    /// The main/master branch name of the dependency
    let branchName: String
    
}

// MARK: - ThirdPartyDependency+Identifiable

extension ThirdPartyDependency: Identifiable {
    
    /// The stable identity of the entity associated with this instance
    var id: String {
        self.displayName
    }
    
}

// MARK: - ThirdPartyDependency+displayName

extension ThirdPartyDependency {
    
    /// The display name
    var displayName: String {
        [
            self.author,
            self.name
        ]
        .joined(separator: "/")
    }
    
}

// MARK: - ThirdPartyDependency+

extension ThirdPartyDependency {
    
    /// The repository URL
    var repositoryURL: URL? {
        .init(
            string: [
                "https://github.com",
                self.author,
                self.name
            ]
            .joined(separator: "/")
        )
    }
    
}

// MARK: - ThirdPartyDependency+licenseURL

extension ThirdPartyDependency {
    
    /// The license URL
    var licenseURL: URL? {
        .init(
            string: [
                "https://raw.githubusercontent.com",
                self.author,
                self.name,
                self.branchName,
                "LICENSE"
            ]
            .joined(separator: "/")
        )
    }
    
}

// MARK: - ThirdPartyDependency+all

extension ThirdPartyDependency {
    
    /// All ThirdPartyDependencies
    static let all: [Self] = [
        .init(
            author: "Google",
            name: "abseil-cpp-binary",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "app-check",
            branchName: "main"
        ),
        .init(
            author: "OpenID",
            name: "AppAuth-iOS",
            branchName: "master"
        ),
        .init(
            author: "Firebase",
            name: "firebase-ios-sdk",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "GoogleAppMeasurement",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "GoogleDataTransport",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "GoogleSignIn-iOS",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "GoogleUtilities",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "grpc-binary",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "gtm-session-fetcher",
            branchName: "main"
        ),
        .init(
            author: "Google",
            name: "GTMAppAuth",
            branchName: "master"
        ),
        .init(
            author: "Google",
            name: "interop-ios-for-google-sdks",
            branchName: "main"
        ),
        .init(
            author: "Firebase",
            name: "leveldb",
            branchName: "firebase-release"
        ),
        .init(
            author: "Firebase",
            name: "nanopb",
            branchName: "master"
        ),
        .init(
            author: "Google",
            name: "promises",
            branchName: "master"
        ),
        .init(
            author: "Apple",
            name: "swift-protobuf",
            branchName: "main"
        )
    ]
    
}
