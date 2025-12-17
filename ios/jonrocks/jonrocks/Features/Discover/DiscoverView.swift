import SwiftUI

struct DiscoverView: View {
  @EnvironmentObject var authService: AuthenticationService
  @State private var discoverVM: DiscoverVM?

  var body: some View {
    NavigationStack {
      VStack(spacing: 12) {
        AppHeader(title: "Discover", onAddTap: nil)
        HStack(spacing: 12) {
          if let discoverVM = discoverVM {
            FilterButton(
              title: "Gym",
              icon: "crashpadIcon",
              isActive: discoverVM.selectedFilterType == "gym",
              action: {
                if discoverVM.selectedFilterType == "gym" {
                  discoverVM.selectedFilterType = nil
                } else {
                  discoverVM.selectedFilterType = "gym"
                }
              }
            )

            FilterButton(
              title: "Crag",
              icon: "camIcon",
              isActive: discoverVM.selectedFilterType == "crag",
              action: {
                if discoverVM.selectedFilterType == "crag" {
                  discoverVM.selectedFilterType = nil
                } else {
                  discoverVM.selectedFilterType = "crag"
                }
              }
            )
          }

          Spacer()
        }
        .padding(.horizontal, 16)

        Group {
          if let discoverVM = discoverVM {
            LocationsContentView(discoverVM: discoverVM)
          } else {
            ProgressView()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
      .onAppear {
        if discoverVM == nil {
          print("🔍 DiscoverView: Creating DiscoverVM")
          discoverVM = DiscoverVM(authService: authService)
          Task {
            print("🔍 DiscoverView: Loading locations...")
            await discoverVM?.loadLocations()
            print("🔍 DiscoverView: Locations loaded, count: \(discoverVM?.locations.count ?? 0)")
          }
        } else {
          print("🔍 DiscoverView: onAppear, locations.count = \(discoverVM?.locations.count ?? 0)")
          // Reload if empty
          if discoverVM?.locations.isEmpty == true && discoverVM?.loading == false {
            print("🔍 DiscoverView: Reloading locations (was empty)")
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
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
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
      } else if discoverVM.filteredLocations.isEmpty {
        VStack(spacing: 12) {
          Text("No locations available")
            .font(.body)
            .foregroundStyle(.secondary)
          VStack(spacing: 4) {
            Text("Debug Info:")
              .font(.caption)
              .fontWeight(.semibold)
            Text("locations.count = \(discoverVM.locations.count)")
              .font(.caption)
            Text("filteredLocations.count = \(discoverVM.filteredLocations.count)")
              .font(.caption)
            Text("selectedFilterType = \(discoverVM.selectedFilterType ?? "nil")")
              .font(.caption)
            Text("loading = \(discoverVM.loading ? "true" : "false")")
              .font(.caption)
            Text("error = \(discoverVM.error ?? "nil")")
              .font(.caption)
          }
          .foregroundStyle(.tertiary)
          .padding()
          Button("Reload") {
            Task {
              await discoverVM.loadLocations()
            }
          }
          .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
          print("🔍 DiscoverView: Showing empty state")
          print("🔍   locations.count = \(discoverVM.locations.count)")
          print("🔍   filteredLocations.count = \(discoverVM.filteredLocations.count)")
          print("🔍   selectedFilterType = \(discoverVM.selectedFilterType ?? "nil")")
        }
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

struct LocationRowView: View {
  let location: LocationDTO

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      VStack(alignment: .leading, spacing: 8) {
        Text(location.name)
          .font(.headline)
          .foregroundColor(Color.theme.accent)
        Text(location.type.capitalized)
          .font(.subheadline)
          .foregroundStyle(Color.theme.textSecondary)
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(Color.theme.background)
          .cornerRadius(8)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.raw.slate500, lineWidth: 1)
          )
      }
    }
    .padding(.vertical, 4)
  }
}

#Preview {
  DiscoverView()
}
