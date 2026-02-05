import SwiftUI

struct RouteRowView: View {
  let route: RouteDTO

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(route.name ?? "Unnamed Route")
            .font(.headline)
            .foregroundColor(Color.theme.accent)
          HStack(spacing: 12) {
            Text(route.discipline.capitalized)
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color(.systemGray6))
              .clipShape(Capsule())
          }
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 4) {
          Text(route.gradeValue)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color.theme.accent)
          routeStarRating(value: route.starRating ?? 0)
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

  private func routeStarRating(value: Int) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      if value > 0 {
        HStack(spacing: 2) {
          ForEach(0..<value, id: \.self) { _ in
            Image(systemName: "star.fill")
              .foregroundColor(.yellow)
          }
        }
      } else {
        Text("0 stars")
          .font(.body)
          .foregroundStyle(Color.theme.textPrimary)
      }
    }
  }
}
