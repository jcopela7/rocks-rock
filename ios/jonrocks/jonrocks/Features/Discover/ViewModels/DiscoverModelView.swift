import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class DiscoverVM: ObservableObject {
  @Published var routes: [RouteDTO] = []
  @Published var locations: [LocationDTO] = []
  @Published var myLocations: [UserLocationDTO] = []
  @Published var loading: Bool = false
  @Published var myLocationsLoading: Bool = false
  @Published var error: String? = nil
  @Published var selectedFilterType: String? = nil  // nil = all, "gym" or "crag"
  @Published var searchText: String = ""
  @Published var isLocationFavourite: Bool = false
  @Published var userLocationIdForFavourite: UUID? = nil
  @Published var favouriteLoading: Bool = false

  var api: APIClient
  private let authService: AuthenticationService
  private var cancellables = Set<AnyCancellable>()

  init(authService: AuthenticationService) {
    self.authService = authService
    self.api = APIClient.shared

    // Debounce search text changes and reload locations
    $searchText
      .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
      .sink { [weak self] searchText in
        Task { @MainActor [weak self] in
          guard let self else { return }
          await self.loadLocations()
          await self.loadMyLocations(name: searchText.isEmpty ? nil : searchText)
        }
      }
      .store(in: &cancellables)
  }

  var filteredLocations: [LocationDTO] {
    let result: [LocationDTO]
    if let filterType = selectedFilterType {
      result = locations.filter { $0.type == filterType }
    } else {
      result = locations
    }
    return result
  }

  /// User's saved locations as LocationDTO for display/navigation
  var filteredMyLocations: [LocationDTO] {
    myLocations.map { ul in
      LocationDTO(
        id: ul.locationId,
        name: ul.name,
        type: ul.type,
        description: ul.description,
        latitude: ul.latitude,
        longitude: ul.longitude
      )
    }
  }

  func loadRoutes() async {
    do {
      routes = try await api.listRoutes()
      self.error = nil
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch let err {
      print("Backend error in loadRoutes(): \(err)")
      self.error = err.localizedDescription
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
      self.error = nil
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch let err {
      print("❌ Backend error in loadLocations(): \(err)")
      print("❌ Error type: \(type(of: err))")
      print("❌ Error details: \(String(describing: err))")
      if let apiError = err as? APIError {
        print("❌ API Error: \(apiError.errorDescription ?? "unknown")")
      }
      locations = []  // Clear locations on error
      self.error = err.localizedDescription
    }
  }

  func loadMyLocations(name: String? = nil) async {
    myLocationsLoading = true
    defer { myLocationsLoading = false }
    do {
      myLocations = try await api.listMyLocations(name: name)
      self.error = nil
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch let err {
      self.error = err.localizedDescription
    }
  }

  func loadFilteredRoutesByLocation(for locationId: UUID) async {

    loading = true
    self.error = nil

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
    } catch let err {
      print("Error loading routes: \(err)")
      self.error = err.localizedDescription
      loading = false
    }
  }

  func loadFavouriteStatus(for locationId: UUID) async {
    do {
      let myLocations = try await api.listMyLocations()
      if let match = myLocations.first(where: { $0.locationId == locationId }) {
        isLocationFavourite = true
        userLocationIdForFavourite = match.id
      } else {
        isLocationFavourite = false
        userLocationIdForFavourite = nil
      }
    } catch _ {
      isLocationFavourite = false
      userLocationIdForFavourite = nil
    }
  }

  func toggleFavourite(locationId: UUID) async {
    guard !favouriteLoading else { return }
    favouriteLoading = true
    defer { favouriteLoading = false }

    do {
      if isLocationFavourite, let userLocationId = userLocationIdForFavourite {
        _ = try await api.deleteUserLocation(userLocationId)
        isLocationFavourite = false
        userLocationIdForFavourite = nil
      } else {
        let created = try await api.createUserLocation(locationId)
        isLocationFavourite = true
        userLocationIdForFavourite = created.id
      }
    } catch let apiError as APIError {
      if case .missingAccessToken = apiError {
        self.error = "Authentication required. Please log in."
      } else {
        self.error = apiError.errorDescription
      }
    } catch let err {
      let message = err.localizedDescription
      self.error = message
    }
  }
}
