import SwiftUI

struct ActivityDetailView: View {
  let ascent: AscentDTO

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 8) {
        ascentHeader
          .padding(.top, 16)
        ascentMetadata
        ascentLocation
        ascentDiscipline
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)
      VStack(alignment: .leading, spacing: 8) {
        if let description = ascent.notes, !description.isEmpty {
          VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
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
    .navigationTitle(ascent.routeName ?? "Route")
    .background(Color.theme.background)
  }

  private var ascentHeader: some View {
    HStack {
      Text("\(ascent.routeName ?? "")")
        .font(.title2)
        .foregroundColor(Color.theme.accent)
      Spacer()
    }
  }

  private var disciplineIconName: String {
    switch ascent.routeDiscipline?.lowercased() {
    case "boulder":
      return "crashpadIcon"
    case "sport":
      return "quickdrawIcon"
    case "trad":
      return "camIcon"
    case "board":
      return "boardIcon"
    default:
      return "quickdrawIcon"
    }
  }

  private var ascentLocation: some View {
    VStack(spacing: 0) {
      HStack(spacing: 4) {
        Image(systemName: "mappin.and.ellipse")
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)
          .foregroundColor(.secondary)
        Text("\(ascent.locationName ?? "")")
          .font(.subheadline)
          .foregroundColor(Color.theme.textSecondary)
      }

    }
  }

  private var ascentMetadata: some View {
    HStack(spacing: 4) {
      Image(systemName: "calendar")
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
        .foregroundColor(.secondary)
      Text("\(ascent.climbedAt.formatted(date: .abbreviated, time: .shortened))")
        .font(.subheadline)
        .foregroundStyle(Color.theme.textSecondary)
    }
  }

  private var ascentDiscipline: some View {
    HStack(spacing: 4) {
      Image(disciplineIconName)
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
        .foregroundColor(.secondary)
      Text("\((ascent.routeDiscipline ?? "").capitalized)")
        .font(.subheadline)
        .foregroundStyle(Color.theme.textSecondary)
    }
  }

}
