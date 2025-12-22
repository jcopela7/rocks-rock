import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class DiscoverVM: ObservableObject {
  @Published var routes: [RouteDTO] = []
  @Published var locations: [LocationDTO] = []
  @Published var loading: Bool = false
  @Published var error: String? = nil
  @Published var selectedFilterType: String? = nil  // nil = all, "gym" or "crag"
  @Published var searchText: String = ""

  var api: APIClient
  private let authService: AuthenticationService
  private var cancellables = Set<AnyCancellable>()

  init(authService: AuthenticationService) {
    self.authService = authService
    self.api = APIClient.shared
    
    // Debounce search text changes and reload locations
    $searchText
      .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        Task { @MainActor [weak self] in
          await self?.loadLocations()
        }
      }
      .store(in: &cancellables)
  }

  var filteredLocations: [LocationDTO] {
    let result: [LocationDTO]
    if let filterType = selectedFilterType {
      result = locations.filter { $0.type == filterType }
      print(
        "🔍 filteredLocations: Filter '\(filterType)', returning \(result.count) of \(locations.count) locations"
      )
    } else {
      result = locations
      print(
        "🔍 filteredLocations: No filter, returning all \(result.count) locations (locations array has \(locations.count))"
      )
    }
    return result
  }

  func loadRoutes() async {
    do {
      routes = try await api.listRoutes()
      error = nil
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch {
      print("Backend error in loadRoutes(): \(error)")
      self.error = error.localizedDescription
    }
  }

  func loadLocations() async {
    loading = true
    defer { loading = false }

    do {
      // Use searchText for backend filtering by name
      let nameFilter = searchText.isEmpty ? nil : searchText
      let loadedLocations = try await api.listLocations(name: nameFilter)
      locations = loadedLocations
      error = nil
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch {
      print("❌ Backend error in loadLocations(): \(error)")
      print("❌ Error type: \(type(of: error))")
      print("❌ Error details: \(String(describing: error))")
      if let apiError = error as? APIError {
        print("❌ API Error: \(apiError.errorDescription ?? "unknown")")
      }
      locations = []  // Clear locations on error
    }
  }

  func loadFilteredRoutesByLocation(for locationId: UUID) async {

    loading = true
    error = nil

    do {
      let allRoutes = try await api.listRoutes()
      routes = allRoutes.filter { $0.locationId == locationId }
      loading = false
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
      loading = false
    } catch {
      print("Error loading routes: \(error)")
      self.error = error.localizedDescription
      loading = false
    }
  }
}
