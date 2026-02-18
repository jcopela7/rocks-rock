import SwiftUI

struct DiscoverView: View {
  @EnvironmentObject var authService: AuthenticationService
  @Binding var locationToOpen: LocationDTO?

  init(locationToOpen: Binding<LocationDTO?> = .constant(nil)) {
    self._locationToOpen = locationToOpen
  }
  @State private var discoverVM: DiscoverVM?
  @State private var selected = "My Locations"
  @State private var navigationPath = NavigationPath()

  private var searchTextBinding: Binding<String> {
    Binding(
      get: { discoverVM?.searchText ?? "" },
      set: { discoverVM?.searchText = $0 }
    )
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 0) {
        AppHeader(title: "Discover")
          .background(Color.white)
        SegmentedPicker(
          selection: $selected,
          segments: ["My Locations", "All Locations"]
        )
        .background(Color.white)
        if discoverVM != nil {
          SearchBar(text: searchTextBinding, placeholder: "Search by location name...")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        Group {
          if let discoverVM = discoverVM {
            if selected == "My Locations" {
              MyLocationsListView(discoverVM: discoverVM)
            } else {
              AllLocationsListView(discoverVM: discoverVM)
            }
          } else {
            LoadingListView()
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
      .background(Color.raw.slate100)
      .onAppear {
        if discoverVM == nil {
          discoverVM = DiscoverVM(authService: authService)
          Task {
            await discoverVM?.loadLocations()
            await discoverVM?.loadMyLocations()
          }
        } else {
          if discoverVM?.locations.isEmpty == true && discoverVM?.loading == false {
            Task {
              await discoverVM?.loadLocations()
              await discoverVM?.loadMyLocations()
            }
          }
        }
        if let location = locationToOpen {
          navigationPath.append(location)
          locationToOpen = nil
        }
      }
      .onChange(of: locationToOpen) { _, newValue in
        if let location = newValue {
          navigationPath.append(location)
          locationToOpen = nil
        }
      }
      .navigationDestination(for: LocationDTO.self) { location in
        LocationDetailView(location: location, authService: authService)
      }
    }
  }
}

#Preview {
  DiscoverView(locationToOpen: .constant(nil))
    .environmentObject(AuthenticationService())
}
