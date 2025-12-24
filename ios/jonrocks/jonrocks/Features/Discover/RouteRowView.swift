import SwiftUI

struct RouteRowView: View {
  let route: RouteDTO

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        if let name = route.name, !name.isEmpty {
          Text(name)
            .font(.headline)
            .foregroundColor(Color.theme.accent)
        } else {
          Text("Unnamed Route")
            .font(.headline)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Text(route.gradeValue)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(Color.theme.accent)
      }

      HStack(spacing: 12) {
        Text(route.discipline.capitalized)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color(.systemGray6))
          .clipShape(Capsule())

        Text(route.gradeSystem)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color(.systemGray6))
          .clipShape(Capsule())

        if let color = route.color, !color.isEmpty {
          Text(color)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
        }
      }
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 16)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.theme.border, lineWidth: 1)
    )
  }
}
