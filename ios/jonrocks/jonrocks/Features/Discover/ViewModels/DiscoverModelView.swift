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

    let api = APIClient()

    var filteredLocations: [LocationDTO] {
        guard let filterType = selectedFilterType else {
            return locations
        }
        return locations.filter { $0.type == filterType }
    }

    func loadRoutes() async {
        do {
            routes = try await api.listRoutes()
            error = nil
        } catch {
            print("Backend error in loadRoutes(): \(error)")
            self.error = error.localizedDescription
        }
    }

    func loadLocations() async {
        do {
            locations = try await api.listLocations()
            error = nil
        } catch {
            print("Backend error in loadLocations(): \(error)")
            self.error = error.localizedDescription
        }
    }
}
