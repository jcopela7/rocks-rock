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

        // All-locations layer tap handlers
        TapInteraction(.layer(LocationClusterId.clusterCircle)) { _, context in
          zoomIntoCluster(proxy: proxy, coordinate: context.coordinate)
          return true
        }
        TapInteraction(.layer(LocationClusterId.unclusteredPoint)) { feature, _ in
          if let location = locationFromFeature(feature) {
            onLocationSelected?(location)
          }
          return true
        }

        // My-locations layer tap handlers
        TapInteraction(.layer(MyLocationClusterId.clusterCircle)) { _, context in
          zoomIntoCluster(proxy: proxy, coordinate: context.coordinate)
          return true
        }
        TapInteraction(.layer(MyLocationClusterId.unclusteredPoint)) { feature, _ in
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
        let allLocations = viewModel.showAllLocationsLayer ? viewModel.mappableLocations : []
        let myLocations = viewModel.showMyLocationsLayer ? viewModel.mappableMyLocations : []
        MapLocationClustering.setup(map: map, locations: allLocations)
        MapLocationClustering.setup(map: map, myLocations: myLocations)
        styleLoaded = true
      }
      .onChange(of: viewModel.mappableLocations) { _, locations in
        guard styleLoaded, let map = proxy.map else { return }
        let visible = viewModel.showAllLocationsLayer ? locations : []
        MapLocationClustering.updateSource(map: map, locations: visible)
      }
      .onChange(of: viewModel.showAllLocationsLayer) { _, show in
        guard styleLoaded, let map = proxy.map else { return }
        let locations = show ? viewModel.mappableLocations : []
        MapLocationClustering.updateSource(map: map, locations: locations)
      }
      .onChange(of: viewModel.mappableMyLocations) { _, myLocations in
        guard styleLoaded, let map = proxy.map else { return }
        let visible = viewModel.showMyLocationsLayer ? myLocations : []
        MapLocationClustering.updateSource(map: map, myLocations: visible)
      }
      .onChange(of: viewModel.showMyLocationsLayer) { _, show in
        guard styleLoaded, let map = proxy.map else { return }
        let myLocations = show ? viewModel.mappableMyLocations : []
        MapLocationClustering.updateSource(map: map, myLocations: myLocations)
      }
      .ignoresSafeArea()
    }
  }

  private func zoomIntoCluster(proxy: MapProxy, coordinate: CLLocationCoordinate2D) {
    if let map = proxy.map {
      let newZoom = min(
        map.cameraState.zoom + MapConstants.clusterZoomIncrement, MapConstants.maxZoom)
      withViewportAnimation(.easeIn(duration: 0.3)) {
        viewport = .camera(center: coordinate, zoom: newZoom, bearing: 0, pitch: 0)
      }
    }
  }

  private func locationFromFeature(_ feature: FeaturesetFeature) -> LocationDTO? {
    guard let id = MapLocationClustering.locationId(from: feature) else { return nil }
    return viewModel.allLocations.first { $0.id == id }
  }
}
