import SwiftUI

// MARK: - ThirdPartyDependencyList

/// The ThirdPartyDependencyList
struct ThirdPartyDependencyList {}

// MARK: - View

extension ThirdPartyDependencyList: View {
    
    /// The content and behavior of the view
    var body: some View {
        List {
            Section {
                ForEach(
                    ThirdPartyDependency.all
                ) { thirdPartyDependency in
                    NavigationLink(
                        destination: ThirdPartyDependencyDetail(
                            thirdPartyDependency: thirdPartyDependency
                        )
                    ) {
                        HStack {
                            Image(
                                systemName: "shippingbox.fill"
                            )
                            .foregroundColor(.primary)
                            .opacity(0.5)
                            VStack(alignment: .leading) {
                                Text(
                                    verbatim: thirdPartyDependency.author
                                )
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                                Text(
                                    verbatim: thirdPartyDependency.name
                                )
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
        .navigationTitle("Licenses")
    }
    
}
