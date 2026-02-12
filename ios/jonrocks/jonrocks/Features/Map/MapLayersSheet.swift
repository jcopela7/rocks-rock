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
      layerSheetFooter
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

  private var layerSheetFooter: some View {
    VStack(spacing: 0) {
      HStack {
        Spacer()
        Button {
          dismiss()
        } label: {
          Text("Done")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.theme.textPrimary)
            .cornerRadius(8)
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .background(Color.white)
    }
    .overlay(alignment: .top) {
      LinearGradient(
        colors: [
          Color.clear,
          Color.theme.textSecondary.opacity(0.08),
          Color.theme.textSecondary.opacity(0.15),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 8)
      .frame(maxWidth: .infinity)
      .offset(y: -8)
    }
  }
}

#Preview {
  MapLayersSheet(viewModel: MapViewModel(authService: AuthenticationService()))
}
