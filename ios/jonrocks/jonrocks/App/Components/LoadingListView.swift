import SwiftUI

/// Shared loading view for list-style pages (Discover / Activity / Locations).
/// Renders a default gray grouped background with a centered circular spinner.
struct LoadingListView: View {
  var body: some View {
    ZStack {
      Color.theme.background
        .ignoresSafeArea()

      ProgressView()
        .progressViewStyle(.circular)
        .tint(.secondary)
        .scaleEffect(1.1)
        .accessibilityLabel("Loading")
    }
  }
}
