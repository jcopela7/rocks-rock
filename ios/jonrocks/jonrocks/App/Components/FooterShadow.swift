import SwiftUI

extension View {
  func footerShadow() -> some View {
    self
      .overlay(alignment: .top) {
        LinearGradient(
          colors: [
            Color.clear,
            Color.theme.textSecondary.opacity(0.08),
            Color.theme.textSecondary.opacity(0.15),
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .frame(height: 8)
        .frame(maxWidth: .infinity)
        .offset(y: -8)
      }
  }
}
