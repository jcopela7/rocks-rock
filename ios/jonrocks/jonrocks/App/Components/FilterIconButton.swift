import SwiftUI

struct FilterIconButton: View {
  let icon: String?
  let title: String?
  let isActive: Bool
  let action: () -> Void

  var body: some View {
    VStack {
      Button(action: action) {
        HStack {
          if let icon = icon {
            Image(icon)
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
              .foregroundColor(isActive ? Color.raw.blue600 : Color.theme.textSecondary)
          }
        }
        .padding(12)
        .background(isActive ? Color.raw.blue100 : Color.raw.slate50)
        .clipShape(Circle())
        .overlay(
          Circle()
            .stroke(isActive ? Color.raw.blue100 : Color.raw.slate500, lineWidth: 1)
        )
      }
      if let title = title {
        Text(title)
          .font(.caption)
          .foregroundColor(isActive ? Color.raw.blue600 : Color.theme.textSecondary)
      }
    }
  }
}
