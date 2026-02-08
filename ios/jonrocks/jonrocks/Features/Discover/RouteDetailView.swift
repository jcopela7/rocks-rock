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
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)

        // Grade
        HStack(alignment: .top, spacing: 12) {
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
        }

        //discipline
        VStack(alignment: .leading, spacing: 8) {
          HStack(spacing: 8) {
            Image(disciplineIconName)
              .resizable()
              .scaledToFit()
              .frame(width: 18, height: 18)
              .foregroundStyle(.secondary)
            Text(route.discipline.capitalized)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(Color(.systemGray6))
          .clipShape(Capsule())
        }
        .padding(.horizontal, 16)

        Rectangle()
          .fill(Color.raw.slate200)
          .frame(height: 1)

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

  private var disciplineIconName: String {
    switch route.discipline.lowercased() {
    case "boulder": return "crashpadIcon"
    case "sport": return "quickdrawIcon"
    case "trad": return "camIcon"
    case "board": return "boardIcon"
    default: return "quickdrawIcon"
    }
  }

  private func routeStarRating(value: Int) -> some View {
    HStack(spacing: 2) {
      if value > 0 {
        ForEach(0..<value, id: \.self) { _ in
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .frame(width: 32, height: 32)
            .scaledToFit()
        }
      } else {
        Text("No rating")
          .font(.body)
          .foregroundStyle(.secondary)
      }
    }
  }
}
