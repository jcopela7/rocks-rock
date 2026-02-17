import CoreLocation
import MapboxMaps
import SwiftUI

private let defaultCenter = CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0)
private let defaultZoom: CGFloat = 3

struct MapView: View {
  @EnvironmentObject var authService: AuthenticationService
  var onLocationSelected: ((LocationDTO) -> Void)? = nil
  @State private var mapVM: MapViewModel?
  @State private var viewport: Viewport = .camera(
    center: defaultCenter, zoom: defaultZoom, bearing: 0, pitch: 0)
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
        VStack {
          Spacer()
          HStack {
            Spacer()
            VStack {
              MapLocateMeButton(viewport: $viewport)
              MapLayersButton(action: { showingLayerSheet = true })
            }
            .padding(.bottom, 8)
            .padding(.trailing, 8)
          }
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

private struct MapContentView: View {
  @ObservedObject var viewModel: MapViewModel
  @Binding var viewport: Viewport
  var onLocationSelected: ((LocationDTO) -> Void)?
  @State private var styleLoaded = false

  var body: some View {
    MapReader { proxy in
      Map(viewport: $viewport) {
        Puck2D(bearing: .heading)
          .showsAccuracyRing(true)

        // Location clustering - tap handlers (always registered; layers empty when hidden)
        TapInteraction(.layer(LocationClusterId.clusterCircle)) { _, context in
          if let map = proxy.map {
            let newZoom = min(map.cameraState.zoom + 3, 22)
            withViewportAnimation(.easeIn(duration: 0.3)) {
              viewport = .camera(center: context.coordinate, zoom: newZoom, bearing: 0, pitch: 0)
            }
          }
          return true
        }
        TapInteraction(.layer(LocationClusterId.unclusteredPoint)) { feature, _ in
          if let location = locationFromFeature(feature) {
            onLocationSelected?(location)
          }
          return true
        }
        TapInteraction { _ in
          false
        }

        // Ascents layer - keep as annotations (no clustering)
        ForEvery(viewModel.showAscentsLayer ? viewModel.mappableAscents : [], id: \.id) { ascent in
          if let lat = ascent.locationLatitude, let lon = ascent.locationLongitude {
            MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
              Circle()
                .fill(Color.theme.accent.opacity(0.8))
                .frame(width: 24, height: 24)
                .overlay(
                  Circle()
                    .stroke(Color.white, lineWidth: 2)
                )
            }
          }
        }
      }
      .onStyleLoaded { _ in
        guard let map = proxy.map else { return }
        let locations = viewModel.showLocationsLayer ? viewModel.mappableLocations : []
        MapLocationClustering.setup(map: map, locations: locations)
        styleLoaded = true
      }
      .onChange(of: viewModel.mappableLocations) { _, locations in
        guard styleLoaded, let map = proxy.map else { return }
        MapLocationClustering.updateSource(map: map, locations: locations)
      }
      .onChange(of: viewModel.showLocationsLayer) { _, show in
        guard styleLoaded, let map = proxy.map else { return }
        let locations = show ? viewModel.mappableLocations : []
        MapLocationClustering.updateSource(map: map, locations: locations)
      }
      .ignoresSafeArea(.all, edges: .bottom)
    }
  }

  private func locationFromFeature(_ feature: FeaturesetFeature) -> LocationDTO? {
    guard let id = MapLocationClustering.locationId(from: feature) else { return nil }
    return viewModel.locations.first { $0.id == id }
  }
}

#Preview {
  MapView()
    .environmentObject(AuthenticationService())
}
