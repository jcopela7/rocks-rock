import Combine
import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
  @Published var myLocations: [UserLocationDTO] = []
  @Published var allLocations: [LocationDTO] = []
  @Published var ascents: [AscentDTO] = []
  @Published var showMyLocationsLayer: Bool = true
  @Published var showAllLocationsLayer: Bool = true
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
    allLocations.filter { $0.latitude != nil && $0.longitude != nil }
  }

  var mappableMyLocations: [UserLocationDTO] {
    myLocations.filter { $0.latitude != nil && $0.longitude != nil }
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
      async let myLocationsTask = api.listMyLocations()
      async let allLocationsTask = api.listLocations()
      async let ascentsTask = api.listAscents(limit: 100)

      let (loadedMyLocations, loadedAllLocations, loadedAscents) = try await (
        myLocationsTask, allLocationsTask, ascentsTask
      )
      myLocations = loadedMyLocations
      allLocations = loadedAllLocations
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
