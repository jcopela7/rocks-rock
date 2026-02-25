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
            Text("Location Layers")
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundColor(Color.theme.textPrimary)

            HStack(spacing: 24) {
              MapLayerImageButton(
                imageName: "allLocations",
                label: "All Locations",
                isSelected: viewModel.showAllLocationsLayer
              ) {
                viewModel.showAllLocationsLayer.toggle()
              }

              MapLayerImageButton(
                imageName: "myLocations",
                label: "My Locations",
                isSelected: viewModel.showMyLocationsLayer
              ) {
                viewModel.showMyLocationsLayer.toggle()
              }
              Spacer()
            }
          }
          .padding(.top, 8)
        }
        .padding(.horizontal, 24)
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
    .padding(.horizontal, 24)
    .padding(.vertical, 16)
    .background(Color.white)
  }
}

struct MapLayerImageButton: View {
  let imageName: String
  let label: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(imageName)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 64, height: 64)
          .clipShape(RoundedRectangle(cornerRadius: 14))
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .stroke(isSelected ? Color.theme.accent : Color.clear, lineWidth: 3)
          )

        Text(label)
          .font(.caption)
          .fontWeight(isSelected ? .semibold : .regular)
          .foregroundColor(isSelected ? Color.theme.accent : Color.theme.textPrimary)
      }
    }
    .buttonStyle(.plain)
    .animation(.easeInOut(duration: 0.15), value: isSelected)
  }
}

#Preview {
  MapLayersSheet(viewModel: MapViewModel(authService: AuthenticationService()))
}
