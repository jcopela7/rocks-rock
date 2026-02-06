import SwiftUI

struct NavigationBarButton: View {
  let title: String
  let systemImage: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Image(systemName: systemImage)
          .font(.system(size: 22))
        Text(title)
          .font(.caption)
      }
      .frame(maxWidth: .infinity)
      .foregroundColor(isSelected ? Color.theme.accent : Color.theme.textPrimary)
    }
    .buttonStyle(.plain)
  }
}
