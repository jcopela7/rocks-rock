import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
  @Published var locations: [LocationDTO] = []
  @Published var ascents: [AscentDTO] = []
  @Published var showLocationsLayer: Bool = true
  @Published var showAscentsLayer: Bool = true
  @Published var loading: Bool = false
  @Published var error: String? = nil

  var api: APIClient
  private let authService: AuthenticationService

  init(authService: AuthenticationService) {
    self.authService = authService
    self.api = APIClient.shared
  }

  var mappableLocations: [LocationDTO] {
    locations.filter { $0.latitude != nil && $0.longitude != nil }
  }

  var mappableAscents: [AscentDTO] {
    ascents.filter {
      $0.locationLatitude != nil && $0.locationLongitude != nil
    }
  }

  func loadData() async {
    loading = true
    defer { loading = false }

    do {
      async let locationsTask = api.listLocations()
      async let ascentsTask = api.listAscents(limit: 100)

      let (loadedLocations, loadedAscents) = try await (locationsTask, ascentsTask)
      locations = loadedLocations
      ascents = loadedAscents
      error = nil
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch {
      self.error = error.localizedDescription
    }
  }
}
