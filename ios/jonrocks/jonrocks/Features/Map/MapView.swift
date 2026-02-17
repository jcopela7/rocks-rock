import MapboxMaps
import SwiftUI

struct MapView: View {
  @EnvironmentObject var authService: AuthenticationService
  var onLocationSelected: ((LocationDTO) -> Void)? = nil
  @State private var mapVM: MapViewModel?
  @State private var viewport: Viewport = .camera(
    center: MapConstants.defaultCenter,
    zoom: MapConstants.defaultZoom,
    bearing: 0,
    pitch: 0)
  @State private var showingLayerSheet = false

  var body: some View {
    ZStack {
      if let mapVM = mapVM {
        if let error = mapVM.error {
          VStack(spacing: 12) {
            Text("Error loading map")
              .font(.headline)
              .foregroundColor(.red)
            Text(error)
              .font(.body)
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
              .padding()
            Button("Retry") {
              Task { await mapVM.loadData() }
            }
            .buttonStyle(.bordered)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          MapContentView(
            viewModel: mapVM, viewport: $viewport, onLocationSelected: onLocationSelected)
        }
      } else {
        LoadingListView()
      }
      if let mapVM = mapVM, mapVM.error == nil {
        MapOverlayButtons {
          MapLocateMeButton(viewport: $viewport)
          MapLayersButton(action: { showingLayerSheet = true })
        }
      }
    }
    .background(Color.raw.slate100)
    .onAppear {
      if mapVM == nil {
        mapVM = MapViewModel(authService: authService)
        Task {
          await mapVM?.loadData()
        }
      }
    }
    .refreshable {
      await mapVM?.loadData()
    }
    .sheet(isPresented: $showingLayerSheet) {
      if let mapVM = mapVM {
        MapLayersSheet(viewModel: mapVM)
      }
    }
  }
}

#Preview {
  MapView()
    .environmentObject(AuthenticationService())
}
