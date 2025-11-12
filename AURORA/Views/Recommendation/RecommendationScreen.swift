import SwiftUI

// MARK: - RecommendationListView

/// Displays the recommendations for the user.
struct RecommendationListView {
    
    /// The user reference.
    private let user: FirestoreEntityReference<User>
    
    /// The recommendations.
    @FirestoreEntityQuery
    private var recommendations: [Recommendation]
    
    // MARK: Initializer
    
    /// Creates a new instance of `RecommendationListView`
    /// - Parameter user: The user reference.
    init(
        user: FirestoreEntityReference<User>
    ) {
        self.user = user
        self._recommendations = .init(
            context: user,
            predicates: [
                Recommendation.orderByCreatedAtPredicate
            ]
        )
    }
    
}

// MARK: - View

extension RecommendationListView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                InfoBox()
            }
            if self.recommendations.isEmpty {
                Section("Your recommendations") {
                    Text("No recommendations yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
            } else {
                Section("Your recommendations") {
                    ForEach(self.recommendations) { recommendation in
                        NavigationLink(
                            destination: RecommendationView(
                                recommendation: recommendation,
                                user: self.user
                            )
                        ) {
                            RecommendationCell(
                                recommendation: recommendation
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Recommendations")
    }
    
}

// MARK: - InfoBox

private struct InfoBox: View {
    
    /// The primary text.
    private let primaryText: LocalizedStringKey = "To help you improve your energy behaviour, AURORA provides you with personalised recommendations based on your energy usage data."
    
    /// The secondary text.
    private let secondaryText: LocalizedStringKey = "Recommendations are updated regularly as you enter more data."
    
    /// The body.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(self.primaryText)
                .font(.body)
            Text(self.secondaryText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
    
}

// MARK: - RecommendationCell

private struct RecommendationCell: View {
    
    /// The recommendation.
    let recommendation: Recommendation
    
    /// The read status.
    private var readStatus: String {
        if self.recommendation.isRead == true {
            return String(localized: "Read")
        } else {
            return String(localized: "Unread")
        }
    }
    
    /// The body.
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(self.recommendation.displayTitle)
                    .fontWeight(self.recommendation.isRead == true ? .regular : .semibold)
                    .foregroundStyle(
                        self.recommendation.isRead == true ? Color.primary : Color.accentColor
                    )
                    .lineLimit(2)
                Spacer()
                if self.recommendation.isRead != true {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.accentColor)
                }
            }
            HStack(spacing: 4) {
                if let createdAt = self.recommendation.createdAtDate {
                    Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                } else {
                    Text("—")
                }
                Text("•")
                Text(self.readStatus)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
    
}
