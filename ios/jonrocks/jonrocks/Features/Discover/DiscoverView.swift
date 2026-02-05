import SwiftUI

struct DiscoverView: View {
  @EnvironmentObject var authService: AuthenticationService
  @State private var discoverVM: DiscoverVM?
  @State private var selected = "My Locations"

  private var searchTextBinding: Binding<String> {
    Binding(
      get: { discoverVM?.searchText ?? "" },
      set: { discoverVM?.searchText = $0 }
    )
  }

  var body: some View {
    NavigationStack {
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
            LocationsContentView(discoverVM: discoverVM)
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
          }
        } else {
          if discoverVM?.locations.isEmpty == true && discoverVM?.loading == false {
            Task {
              await discoverVM?.loadLocations()
            }
          }
        }
      }
    }
  }
}

struct LocationsContentView: View {
  @EnvironmentObject var authService: AuthenticationService
  @ObservedObject var discoverVM: DiscoverVM

  var body: some View {
    Group {
      if discoverVM.loading {
        LoadingListView()
      } else if let error = discoverVM.error {
        VStack(spacing: 12) {
          Text("Error loading locations")
            .font(.headline)
            .foregroundColor(.red)
          Text(error)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding()
          Button("Retry") {
            Task {
              await discoverVM.loadLocations()
            }
          }
          .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      } else {
        List(discoverVM.filteredLocations) { location in
          NavigationLink(
            destination: LocationDetailView(
              location: location,
              authService: authService
            )
          ) {
            LocationRowView(location: location)
          }
          .listRowSeparator(.visible)
        }
        .listStyle(.plain)
        .contentMargins(.horizontal, 12)
        .background(Color.theme.card)
      }
    }
  }
}

#Preview {
  DiscoverView()
}
