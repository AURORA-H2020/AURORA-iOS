import LinkPresentation
import SwiftUI

// MARK: - ThirdPartyDependencyDetail

/// The ThirdPartyDependencyDetail
struct ThirdPartyDependencyDetail {
    
    // MARK: Static-Properties
    
    /// The URLSession
    private static let urlSession = URLSession(
        configuration: {
            let configuration = URLSessionConfiguration.default
            configuration.urlCache = .shared
            return configuration
        }()
    )
    
    // MARK: Properties
    
    /// The ThirdPartyDependency
    let thirdPartyDependency: ThirdPartyDependency
    
    /// The LinkPresentation Metadata
    @State
    private var metadata: LPLinkMetadata?
    
    /// The License
    @State
    private var license: String?
    
}

// MARK: - View

extension ThirdPartyDependencyDetail: View {
    
    /// The content and behavior of the view
    var body: some View {
        List {
            Section(
                header: Group {
                    if let metadata = self.metadata {
                        LPLinkView.Representable(
                            metaData: metadata
                        )
                    } else {
                        LPLinkView.Representable(
                            url: self.thirdPartyDependency.repositoryURL
                        )
                    }
                },
                footer: Group {
                    if let license = self.license {
                        Text(
                            verbatim: license
                        )
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                    }
                }
            ) {}
        }
        .navigationTitle(self.thirdPartyDependency.name)
        .task {
            // Verify license URL is availabe
            guard let licenseURL = self.thirdPartyDependency.licenseURL else {
                // Otherwise return out of function
                return
            }
            // Initialize URLRequests
            let urlRequests: [URLRequest] = [
                .init(url: licenseURL),
                .init(url: licenseURL.appendingPathExtension("txt"))
            ]
            // Verify license data is available
            guard let licenseData: Data = await {
                // For each URLRequest
                for urlRequest in urlRequests {
                    // Verify data and response are available
                    guard let (data, response) = try? await Self.urlSession.data(for: urlRequest) else {
                        // Otherwise continue with next request
                        continue
                    }
                    // Verify status code is equal to 200 (OK)
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        // Otherwise continue with next request
                        continue
                    }
                    // Return data
                    return data
                }
                // Otherwise return nil
                return nil
            }() else {
                // Otherwise return out of function
                return
            }
            // Set license
            self.license = .init(decoding: licenseData, as: UTF8.self)
        }
        .task {
            // Verify repository URL is available
            guard let repositoryURL = self.thirdPartyDependency.repositoryURL else {
                // Otherwise return out of function
                return
            }
            // Initialize LPMetadataProvider
            let metadataProvider = LPMetadataProvider()
            // Load metadata
            self.metadata = try? await metadataProvider
                .startFetchingMetadata(for: repositoryURL)
        }
    }
    
}

// MARK: - LPLinkView+Representable

private extension LPLinkView {
    
    /// A LPLinkView SwiftUI Representable UIView
    struct Representable: UIViewRepresentable {
        
        // MARK: Properties
        
        /// The URL
        var url: URL?
        
        /// The LPLinkMetadata
        var metaData: LPLinkMetadata?
        
        // MARK: UIViewRepresentable
        
        /// Make LPLinkView
        /// - Parameter context: The Context
        func makeUIView(
            context: Context
        ) -> LPLinkView {
            self.url.flatMap { .init(url: $0) } ?? .init()
        }
        
        /// Update LPLinkView
        /// - Parameters:
        ///   - linkView: The LPLinkView
        ///   - context: The Context
        func updateUIView(
            _ linkView: LPLinkView,
            context: Context
        ) {
            self.metaData.flatMap { linkView.metadata = $0 }
        }
        
    }
    
}
