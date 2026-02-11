import SwiftUI

struct FilterButton: View {
  let title: String
  let icon: String?
  let isActive: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        if let icon = icon {
          Image(icon)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(isActive ? .white : Color.theme.textSecondary)
        }
        Text(title)
          .fontWeight(.semibold)
          .foregroundColor(isActive ? .white : Color.theme.textSecondary)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(isActive ? Color.theme.accent : Color.white)
      .cornerRadius(24)
      .overlay(
        RoundedRectangle(cornerRadius: 24)
          .stroke(isActive ? Color.theme.accent : Color.raw.slate500, lineWidth: 1)
      )
    }
  }
}
