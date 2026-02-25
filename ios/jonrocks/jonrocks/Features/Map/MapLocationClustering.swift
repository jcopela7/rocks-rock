import CoreLocation
import MapboxMaps
import SwiftUI

// MARK: - Location Clustering IDs (All Locations)
// Used by MapContentView for TapInteraction layer targets and by setup/update logic.
enum LocationClusterId {
  static let clusterCircle = "location-cluster-circle"
  static let unclusteredPoint = "location-unclustered-point"
  static let clusterCount = "location-cluster-count"
  static let source = "location-cluster-source"
}

// MARK: - Location Clustering IDs (My Locations)
enum MyLocationClusterId {
  static let clusterCircle = "my-location-cluster-circle"
  static let unclusteredPoint = "my-location-unclustered-point"
  static let clusterCount = "my-location-cluster-count"
  static let source = "my-location-cluster-source"
}

// MARK: - Location Clustering Setup
/// Handles GeoJSON source and layer setup for clustered location points on the map.
/// All locations are rendered in blue; my locations are rendered in orange.
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
      try map.addLayer(
        createClusterCircleLayer(
          layerId: LocationClusterId.clusterCircle,
          sourceId: LocationClusterId.source,
          color: .systemOrange
        ))
      try map.addLayer(
        createUnclusteredPointLayer(
          layerId: LocationClusterId.unclusteredPoint,
          sourceId: LocationClusterId.source,
          color: .systemOrange
        ),
        layerPosition: .below(LocationClusterId.clusterCircle)
      )
      try map.addLayer(
        createClusterCountLayer(
          layerId: LocationClusterId.clusterCount,
          sourceId: LocationClusterId.source
        ))
    } catch {
      print("MapLocationClustering: Failed to setup all-locations clustering: \(error)")
    }
  }

  static func setup(map: MapboxMap, myLocations: [UserLocationDTO]) {
    let featureCollection = makeFeatureCollection(from: myLocations)
    var source = GeoJSONSource(id: MyLocationClusterId.source)
    source.data = .featureCollection(featureCollection)
    source.cluster = true
    source.clusterRadius = clusterRadius

    do {
      try map.addSource(source)
      try map.addLayer(
        createClusterCircleLayer(
          layerId: MyLocationClusterId.clusterCircle,
          sourceId: MyLocationClusterId.source,
          color: .systemBlue
        ))
      try map.addLayer(
        createUnclusteredPointLayer(
          layerId: MyLocationClusterId.unclusteredPoint,
          sourceId: MyLocationClusterId.source,
          color: .systemBlue
        ),
        layerPosition: .below(MyLocationClusterId.clusterCircle)
      )
      try map.addLayer(
        createClusterCountLayer(
          layerId: MyLocationClusterId.clusterCount,
          sourceId: MyLocationClusterId.source
        ))
    } catch {
      print("MapLocationClustering: Failed to setup my-locations clustering: \(error)")
    }
  }

  static func updateSource(map: MapboxMap, locations: [LocationDTO]) {
    let featureCollection = makeFeatureCollection(from: locations)
    map.updateGeoJSONSource(
      withId: LocationClusterId.source,
      data: .featureCollection(featureCollection)
    )
  }

  static func updateSource(map: MapboxMap, myLocations: [UserLocationDTO]) {
    let featureCollection = makeFeatureCollection(from: myLocations)
    map.updateGeoJSONSource(
      withId: MyLocationClusterId.source,
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

  static func makeFeatureCollection(from myLocations: [UserLocationDTO]) -> FeatureCollection {
    let features = myLocations.compactMap { location -> Feature? in
      guard let lat = location.latitude, let lon = location.longitude else { return nil }
      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      var feature = Feature(geometry: .point(Point(coordinate)))
      feature.properties = [
        "location_id": .string(location.locationId.uuidString),
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

  private static func createClusterCircleLayer(
    layerId: String,
    sourceId: String,
    color: UIColor
  ) -> CircleLayer {
    var layer = CircleLayer(id: layerId, source: sourceId)
    layer.filter = Exp(.has) { "point_count" }
    layer.circleColor = .constant(StyleColor(color))
    layer.circleRadius = .constant(25)
    layer.circleStrokeWidth = .constant(2)
    layer.circleStrokeColor = .constant(StyleColor(.white))
    return layer
  }

  private static func createUnclusteredPointLayer(
    layerId: String,
    sourceId: String,
    color: UIColor
  ) -> CircleLayer {
    var layer = CircleLayer(id: layerId, source: sourceId)
    layer.filter = Exp(.not) { Exp(.has) { "point_count" } }
    layer.circleColor = .constant(StyleColor(color))
    layer.circleRadius = .constant(14)
    layer.circleStrokeWidth = .constant(3)
    layer.circleStrokeColor = .constant(StyleColor(.white))
    return layer
  }

  private static func createClusterCountLayer(
    layerId: String,
    sourceId: String
  ) -> SymbolLayer {
    var layer = SymbolLayer(id: layerId, source: sourceId)
    layer.filter = Exp(.has) { "point_count" }
    layer.textField = .expression(Exp(.get) { "point_count" })
    layer.textSize = .constant(14)
    layer.textColor = .constant(StyleColor(.white))
    layer.textAllowOverlap = .constant(true)
    return layer
  }
}
