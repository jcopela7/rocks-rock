import CoreLocation
import MapboxMaps
import SwiftUI

// MARK: - Location Clustering IDs
// Used by MapContentView for TapInteraction layer targets and by setup/update logic.
enum LocationClusterId {
  static let clusterCircle = "location-cluster-circle"
  static let unclusteredPoint = "location-unclustered-point"
  static let clusterCount = "location-cluster-count"
  static let source = "location-cluster-source"
}

// MARK: - Location Clustering Setup
/// Handles GeoJSON source and layer setup for clustered location points on the map.
struct MapLocationClustering {
  static let clusterRadius: Double = 75

  static func setup(map: MapboxMap, locations: [LocationDTO]) {
    let featureCollection = makeFeatureCollection(from: locations)

    var source = GeoJSONSource(id: LocationClusterId.source)
    source.data = .featureCollection(featureCollection)
    source.cluster = true
    source.clusterRadius = clusterRadius

    do {
      try map.addSource(source)
      try map.addLayer(createClusterCircleLayer())
      try map.addLayer(
        createUnclusteredPointLayer(),
        layerPosition: .below(LocationClusterId.clusterCircle)
      )
      try map.addLayer(createClusterCountLayer())
    } catch {
      print("MapLocationClustering: Failed to setup clustering: \(error)")
    }
  }

  static func updateSource(map: MapboxMap, locations: [LocationDTO]) {
    let featureCollection = makeFeatureCollection(from: locations)
    map.updateGeoJSONSource(
      withId: LocationClusterId.source,
      data: .featureCollection(featureCollection)
    )
  }

  static func makeFeatureCollection(from locations: [LocationDTO]) -> FeatureCollection {
    let features = locations.compactMap { location -> Feature? in
      guard let lat = location.latitude, let lon = location.longitude else { return nil }
      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      var feature = Feature(geometry: .point(Point(coordinate)))
      feature.properties = [
        "location_id": .string(location.id.uuidString),
        "name": .string(location.name),
      ]
      return feature
    }
    return FeatureCollection(features: features)
  }

  static func locationId(from feature: FeaturesetFeature) -> UUID? {
    guard case .string(let idString) = feature.properties["location_id"],
      let id = UUID(uuidString: idString)
    else { return nil }
    return id
  }

  // MARK: - Layer Factories

  private static func createClusterCircleLayer() -> CircleLayer {
    let accentColor = Color.theme.accent.toUIColor()
    var layer = CircleLayer(id: LocationClusterId.clusterCircle, source: LocationClusterId.source)
    layer.filter = Exp(.has) { "point_count" }
    layer.circleColor = .expression(
      Exp(.step) {
        Exp(.get) { "point_count" }
        accentColor
        10
        UIColor.systemBlue
        50
        UIColor.systemOrange
        100
        UIColor.systemRed
      })
    layer.circleRadius = .constant(25)
    layer.circleStrokeWidth = .constant(2)
    layer.circleStrokeColor = .constant(StyleColor(.white))
    return layer
  }

  private static func createUnclusteredPointLayer() -> CircleLayer {
    var layer = CircleLayer(
      id: LocationClusterId.unclusteredPoint,
      source: LocationClusterId.source
    )
    layer.filter = Exp(.not) { Exp(.has) { "point_count" } }
    layer.circleColor = .constant(StyleColor(Color.theme.accent.toUIColor()))
    layer.circleRadius = .constant(14)
    layer.circleStrokeWidth = .constant(3)
    layer.circleStrokeColor = .constant(StyleColor(.white))
    return layer
  }

  private static func createClusterCountLayer() -> SymbolLayer {
    var layer = SymbolLayer(id: LocationClusterId.clusterCount, source: LocationClusterId.source)
    layer.filter = Exp(.has) { "point_count" }
    layer.textField = .expression(Exp(.get) { "point_count" })
    layer.textSize = .constant(14)
    layer.textColor = .constant(StyleColor(.white))
    layer.textHaloColor = .constant(StyleColor(.darkGray))
    layer.textHaloWidth = .constant(1)
    layer.textAllowOverlap = .constant(true)
    return layer
  }
}

// MARK: - Color Extension for Mapbox Styling
extension Color {
  fileprivate func toUIColor() -> UIColor {
    UIColor(self)
  }
}
