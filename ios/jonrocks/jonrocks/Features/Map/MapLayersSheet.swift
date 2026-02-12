import SwiftUI

struct MapLayersSheet: View {
  @ObservedObject var viewModel: MapViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack(spacing: 0) {
      layersHeader
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          VStack(alignment: .leading, spacing: 12) {
            Text("Map Layers")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundColor(Color.theme.textPrimary)

            Toggle(
              isOn: Binding(
                get: { viewModel.showLocationsLayer },
                set: { viewModel.showLocationsLayer = $0 }
              )
            ) {
              Label("Locations", systemImage: "mappin.circle.fill")
                .foregroundColor(Color.theme.textPrimary)
            }
            .tint(Color.theme.accent)
            Toggle(
              isOn: Binding(
                get: { viewModel.showAscentsLayer },
                set: { viewModel.showAscentsLayer = $0 }
              )
            ) {
              Label("Ascents", systemImage: "circle.fill")
                .foregroundColor(Color.theme.textPrimary)
            }
            .tint(Color.theme.accent)
          }
          .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
      }
    }
    .background(Color.white)
    .foregroundColor(Color.theme.textPrimary)
    .presentationDetents([.medium])
  }

  private var layersHeader: some View {
    HStack {
      Text("Layers")
        .font(.headline)
        .fontWeight(.bold)
        .foregroundColor(Color.theme.textPrimary)
      Spacer()
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(Color.theme.textPrimary)
          .frame(width: 32, height: 32)
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(Color.white)
  }
}

#Preview {
  MapLayersSheet(viewModel: MapViewModel(authService: AuthenticationService()))
}
