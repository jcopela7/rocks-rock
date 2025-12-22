import SwiftUI

struct LocationRowView: View {
  let location: LocationDTO

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      VStack(alignment: .leading, spacing: 8) {
        Text(location.name)
          .font(.headline)
          .foregroundColor(Color.theme.accent)
        Text(location.type.capitalized)
          .font(.subheadline)
          .foregroundStyle(Color.theme.textSecondary)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(Color.theme.background)
          .cornerRadius(8)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.raw.slate500, lineWidth: 1)
          )
      }
    }
    .padding(.vertical, 4)
  }
}
