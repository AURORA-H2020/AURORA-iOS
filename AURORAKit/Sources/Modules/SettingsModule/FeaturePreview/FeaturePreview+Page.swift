import SwiftUI

// MARK: - FeaturePreview+Page

extension FeaturePreview {
    
    /// A FeaturePreview Page
    struct Page {
        
        /// The image resource name
        let imageName: String
        
        /// The description text
        let description: String
        
        /// Bool value if description is hidden
        @State
        private var isDescriptionHidden = false
        
    }
    
}

// MARK: - View

extension FeaturePreview.Page: View {
    
    /// The content and behavior of the view.
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(
                self.imageName,
                bundle: .module
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            Text(
                verbatim: self.description
            )
            .multilineTextAlignment(.center)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(8)
            .padding()
            .opacity(self.isDescriptionHidden ? 0 : 1)
        }
        .onTapGesture {
            self.isDescriptionHidden.toggle()
        }
        .onAppear {
            self.isDescriptionHidden = false
        }
        .animation(
            .default,
            value: self.isDescriptionHidden
        )
    }
    
}
