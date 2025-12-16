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
    @Published var selectedFilterType: String? = nil // nil = all, "gym" or "crag"

    var api: APIClient
    private let authService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthenticationService) {
        self.authService = authService
        // Initialize API client with access token (may be nil initially)
        self.api = APIClient(accessToken: authService.accessToken)
        
        // Update API client when access token changes
        authService.$accessToken
            .sink { [weak self] token in
                guard let self = self else { return }
                print("🔄 DiscoverVM: Updating API client with new token: \(token != nil ? "present" : "nil")")
                self.api = APIClient(accessToken: token)
            }
            .store(in: &cancellables)
    }

    var filteredLocations: [LocationDTO] {
        let result: [LocationDTO]
        if let filterType = selectedFilterType {
            result = locations.filter { $0.type == filterType }
            print("🔍 filteredLocations: Filter '\(filterType)', returning \(result.count) of \(locations.count) locations")
        } else {
            result = locations
            print("🔍 filteredLocations: No filter, returning all \(result.count) locations (locations array has \(locations.count))")
        }
        return result
    }

    func loadRoutes() async {
        // Ensure we have a token before making the request
        if authService.accessToken == nil {
            print("⏳ Waiting for access token...")
            // Wait for token to become available (with timeout)
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                if authService.accessToken != nil {
                    break
                }
            }
        }
        
        // Ensure API client has the latest token
        if let token = authService.accessToken {
            self.api = APIClient(accessToken: token)
        }
        
        // Double-check we have a token
        guard authService.accessToken != nil else {
            self.error = "Authentication required. Please log in."
            print("❌ No access token available for loadRoutes()")
            return
        }
        
        do {
            routes = try await api.listRoutes()
            error = nil
        } catch {
            print("Backend error in loadRoutes(): \(error)")
            self.error = error.localizedDescription
        }
    }

    func loadLocations() async {
        loading = true
        defer { loading = false }
        
        // Ensure we have a token before making the request
        if authService.accessToken == nil {
            print("⏳ Waiting for access token...")
            // Wait for token to become available (with timeout)
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                if authService.accessToken != nil {
                    break
                }
            }
        }
        
        // Ensure API client has the latest token
        if let token = authService.accessToken {
            self.api = APIClient(accessToken: token)
        }
        
        // Double-check we have a token
        guard authService.accessToken != nil else {
            self.error = "Authentication required. Please log in."
            print("❌ No access token available for loadLocations()")
            return
        }
        
        do {
            let loadedLocations = try await api.listLocations()
            locations = loadedLocations
            error = nil
        } catch {
            print("❌ Backend error in loadLocations(): \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error details: \(String(describing: error))")
            if let apiError = error as? APIError {
                print("❌ API Error: \(apiError.errorDescription ?? "unknown")")
            }
            locations = [] // Clear locations on error
        }
    }

     func loadFilteredRoutesByLocation(for locationId: UUID) async {

        if authService.accessToken == nil {
            print("⏳ Waiting for access token...")
            // Wait for token to become available (with timeout)
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                if authService.accessToken != nil {
                    break
                }
            }
        }

        // Ensure API client has the latest token
        if let token = authService.accessToken {
            self.api = APIClient(accessToken: token)
        }

        loading = true
        error = nil

        do {
            let allRoutes = try await api.listRoutes()
            routes = allRoutes.filter { $0.locationId == locationId }
            loading = false
        } catch {
            print("Error loading routes: \(error)")
            self.error = error.localizedDescription
            loading = false
        }
    }
}
