import SwiftUI

struct RouteDetailView: View {
  let route: RouteDTO

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Header
        VStack(alignment: .leading, spacing: 8) {
          Text(route.name ?? "Unnamed Route")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.theme.accent)

          HStack(spacing: 12) {
            Text(route.discipline.capitalized)
              .font(.subheadline)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(Color(.systemGray6))
              .clipShape(Capsule())
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)

        Rectangle()
          .fill(Color.raw.slate200)
          .frame(height: 1)
          .padding(.horizontal, 16)

        // Grade
        VStack(alignment: .leading, spacing: 8) {
          Text("Grade")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
          Text(route.gradeValue)
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(Color.theme.accent)
        }
        .padding(.horizontal, 16)

        // Stars
        VStack(alignment: .leading, spacing: 8) {
          Text("Rating")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
          routeStarRating(value: route.starRating ?? 0)
        }
        .padding(.horizontal, 16)

        // Description
        if let description = route.description, !description.isEmpty {
          VStack(alignment: .leading, spacing: 8) {
            Text("Description")
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundStyle(.secondary)
            Text(description)
              .font(.body)
              .foregroundStyle(Color.theme.textPrimary)
          }
          .padding(.horizontal, 16)
        }
      }
      .padding(.bottom, 24)
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(route.name ?? "Route")
    .background(Color.theme.background)
  }

  private func routeStarRating(value: Int) -> some View {
    HStack(spacing: 2) {
      if value > 0 {
        ForEach(0..<value, id: \.self) { _ in
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
        }
        Text("\(value) star\(value == 1 ? "" : "s")")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .padding(.leading, 4)
      } else {
        Text("No rating")
          .font(.body)
          .foregroundStyle(.secondary)
      }
    }
  }
}
