import SwiftUI

struct DiscoverView: View {
  @EnvironmentObject var authService: AuthenticationService
  @State private var discoverVM: DiscoverVM?

  var body: some View {
    NavigationStack {
      VStack(spacing: 12) {
        AppHeader(title: "Discover")
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
            LoadingListView()
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
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
      }
      else {
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
