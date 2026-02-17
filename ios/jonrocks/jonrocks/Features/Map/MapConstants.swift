import CoreLocation
import MapboxMaps

enum MapConstants {
  static let defaultCenter = CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0)
  static let defaultZoom: CGFloat = 3
  static let maxZoom: CGFloat = 22
  static let locateMeZoom: CGFloat = 14
  static let clusterZoomIncrement: CGFloat = 2
}
