import SwiftUI

// MARK: - RecommendationView

/// The RecommendationView
struct RecommendationView {
    
    /// The recommendation.
    @State
    private var recommendation: Recommendation
    
    /// The user reference.
    private let user: FirestoreEntityReference<User>
    
    /// Bool value if delete confirmation dialog is presented.
    @State
    private var isDeleteConfirmationDialogPresented = false
    
    /// The Firebase instance.
    @EnvironmentObject
    private var firebase: Firebase
    
    /// The dismiss action.
    @Environment(\.dismiss)
    private var dismiss
    
    /// The openURL action.
    @Environment(\.openURL)
    private var openURL
    
    // MARK: Initializer
    
    /// Creates a new instance of `RecommendationView`
    /// - Parameters:
    ///   - recommendation: The recommendation.
    ///   - user: The user reference.
    init(
        recommendation: Recommendation,
        user: FirestoreEntityReference<User>
    ) {
        self._recommendation = State(initialValue: recommendation)
        self.user = user
    }
    
}

// MARK: - View

extension RecommendationView: View {
    
    /// The content and behavior of the view.
    var body: some View {
        List {
            Section {
                LabeledContent("Status") {
                    Text(self.readStatusTitle)
                        .foregroundStyle(
                            self.recommendation.isRead == true ? .secondary : Color.accentColor
                        )
                }
                if let createdAt = self.recommendation.createdAtDate {
                    LabeledContent("Created") {
                        Text(
                            createdAt.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                        .foregroundStyle(.secondary)
                    }
                }
            }
            Section("Recommendation") {
                Text(self.recommendation.message)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            if let linkURL = self.recommendation.linkURL {
                Section("Learn more") {
                    Button {
                        self.openURL(linkURL)
                    } label: {
                        Text("Learn more")
                            .font(.body.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle(self.recommendation.displayTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        self.toggleReadStatus()
                    } label: {
                        Label(
                            self.toggleReadStatusTitle,
                            systemImage: self.recommendation.isRead == true ? "envelope.badge" : "envelope.open"
                        )
                    }
                    Button(role: .destructive) {
                        self.isDeleteConfirmationDialogPresented = true
                    } label: {
                        Label(
                            "Delete",
                            systemImage: "trash"
                        )
                    }
                    .tint(.red)
                } label: {
                    Image(
                        systemName: "ellipsis.circle"
                    )
                }
                .confirmationDialog(
                    "Delete Recommendation",
                    isPresented: self.$isDeleteConfirmationDialogPresented,
                    actions: {
                        Button(role: .destructive) {
                            self.deleteRecommendation()
                        } label: {
                            Text("Delete")
                        }
                        Button(role: .cancel) {
                        } label: {
                            Text("Cancel")
                        }
                    },
                    message: {
                        Text("Are you sure you want to delete this recommendation?")
                    }
                )
            }
        }
    }
    
}

// MARK: - Private API

private extension RecommendationView {
    
    /// The read status title.
    var readStatusTitle: String {
        if self.recommendation.isRead == true {
            return String(localized: "Read")
        } else {
            return String(localized: "Unread")
        }
    }
    
    /// The toggle read status title.
    var toggleReadStatusTitle: String {
        if self.recommendation.isRead == true {
            return String(localized: "Mark unread")
        } else {
            return String(localized: "Mark read")
        }
    }
    
    /// Toggles the read status.
    func toggleReadStatus() {
        var updatedRecommendation = self.recommendation
        updatedRecommendation.isRead = !(self.recommendation.isRead ?? false)
        try? self.firebase
            .firestore
            .update(
                updatedRecommendation,
                context: self.user
            )
        self.recommendation = updatedRecommendation
    }
    
    /// Deletes the recommendation.
    func deleteRecommendation() {
        try? self.firebase
            .firestore
            .delete(
                self.recommendation,
                context: self.user
            )
        self.dismiss()
    }
    
}
