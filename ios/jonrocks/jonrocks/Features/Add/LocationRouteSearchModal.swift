import SwiftUI

enum SearchMode {
  case location
  case route
}

struct LocationRouteSearchModal: View {
  @ObservedObject var discoverVM: DiscoverVM
  @Binding var selectedLocationId: UUID?
  @Binding var selectedRouteId: UUID?
  @Binding var isPresented: Bool

  let filteredRoutes: [RouteDTO]
  let routeNameFormatter: (RouteDTO) -> String

  @State private var searchMode: SearchMode
  @State private var searchText: String = ""
  @Environment(\.dismiss) private var dismiss

  init(
    discoverVM: DiscoverVM,
    selectedLocationId: Binding<UUID?>,
    selectedRouteId: Binding<UUID?>,
    isPresented: Binding<Bool>,
    filteredRoutes: [RouteDTO],
    routeNameFormatter: @escaping (RouteDTO) -> String
  ) {
    self.discoverVM = discoverVM
    self._selectedLocationId = selectedLocationId
    self._selectedRouteId = selectedRouteId
    self._isPresented = isPresented
    self.filteredRoutes = filteredRoutes
    self.routeNameFormatter = routeNameFormatter

    // Start in route mode if location is already selected, otherwise location mode
    self._searchMode = State(
      initialValue: selectedLocationId.wrappedValue != nil ? .route : .location)
  }

  var filteredLocations: [LocationDTO] {
    if searchText.isEmpty {
      return discoverVM.locations
    }
    return discoverVM.locations.filter { location in
      location.name.localizedCaseInsensitiveContains(searchText)
    }
  }

  var filteredRoutesForSearch: [RouteDTO] {
    let routes = filteredRoutes
    if searchText.isEmpty {
      return routes
    }
    return routes.filter { route in
      let name = routeNameFormatter(route)
      return name.localizedCaseInsensitiveContains(searchText)
    }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Search Bar
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
          TextField(
            searchMode == .location ? "Search locations..." : "Search routes...",
            text: $searchText
          )
          .textFieldStyle(.plain)
          .autocorrectionDisabled()
          .textInputAutocapitalization(.never)

          if !searchText.isEmpty {
            Button(action: { searchText = "" }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.top, 8)

        // Results List
        if searchMode == .location {
          locationList
        } else {
          routeList
        }
      }
      .navigationTitle(searchMode == .location ? "Select Location" : "Select Route")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if searchMode == .route {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
              searchMode = .location
              searchText = ""
            }) {
              HStack {
                Image(systemName: "chevron.left")
                Text("Back")
              }
            }
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Cancel") {
            isPresented = false
          }
        }
      }
    }
  }

  private var locationList: some View {
    Group {
      if filteredLocations.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 48))
            .foregroundColor(.secondary)
          Text(searchText.isEmpty ? "No locations available" : "No locations found")
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      } else {
        List {
          ForEach(filteredLocations, id: \.id) { location in
            Button(action: {
              selectedLocationId = location.id
              selectedRouteId = nil
              searchMode = .route
              searchText = ""
            }) {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text(location.name)
                    .foregroundColor(.primary)
                    .font(.body)
                  if !location.type.isEmpty {
                    Text(location.type.capitalized)
                      .foregroundColor(.secondary)
                      .font(.caption)
                  }
                }
                Spacer()
                if selectedLocationId == location.id {
                  Image(systemName: "checkmark")
                    .foregroundColor(.theme.accent)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        }
        .listStyle(.plain)
      }
    }
  }

  private var routeList: some View {
    Group {
      if filteredRoutesForSearch.isEmpty {
        VStack(spacing: 16) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 48))
            .foregroundColor(.secondary)
          Text(searchText.isEmpty ? "No routes available" : "No routes found")
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      } else {
        List {
          ForEach(filteredRoutesForSearch, id: \.id) { route in
            Button(action: {
              selectedRouteId = route.id
              isPresented = false
            }) {
              HStack {
                Text(routeNameFormatter(route))
                  .foregroundColor(.primary)
                  .font(.body)
                Spacer()
                if selectedRouteId == route.id {
                  Image(systemName: "checkmark")
                    .foregroundColor(.theme.accent)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        }
        .listStyle(.plain)
      }
    }
  }
}
