import SwiftUI

struct ClimbTypeRow: View {
  let icon: String
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(alignment: .center, spacing: 24) {
        Image(icon)
          .resizable()
          .scaledToFit()
          .frame(width: 36, height: 36)
          .foregroundColor(Color.theme.textSecondary)
        Text(title)
          .font(.headline)
          .foregroundColor(Color.theme.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.horizontal, 16)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  ClimbTypeDrawer { _ in }
}
