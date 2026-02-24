import CoreLocation
import MapboxMaps
import SwiftUI

struct MapContentView: View {
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
            let newZoom = min(
              map.cameraState.zoom + MapConstants.clusterZoomIncrement, MapConstants.maxZoom)
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
      }
      .ornamentOptions(OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden)))
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
      .ignoresSafeArea()
    }
  }

  private func locationFromFeature(_ feature: FeaturesetFeature) -> LocationDTO? {
    guard let id = MapLocationClustering.locationId(from: feature) else { return nil }
    return viewModel.locations.first { $0.id == id }
  }
}
