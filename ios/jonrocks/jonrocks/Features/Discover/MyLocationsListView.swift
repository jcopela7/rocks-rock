import SwiftUI

struct MyLocationsListView: View {
  @EnvironmentObject var authService: AuthenticationService
  @ObservedObject var discoverVM: DiscoverVM

  var body: some View {
    Group {
      if discoverVM.myLocationsLoading {
        LoadingListView()
      } else if let error = discoverVM.error {
        VStack(spacing: 12) {
          Text("Error loading your locations")
            .font(.headline)
            .foregroundColor(.red)
          Text(error)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding()
          Button("Retry") {
            Task {
              await discoverVM.loadMyLocations(
                name: discoverVM.searchText.isEmpty ? nil : discoverVM.searchText)
            }
          }
          .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
      } else if discoverVM.filteredMyLocations.isEmpty {
        LoadingListView()
      } else {
        List(discoverVM.filteredMyLocations) { location in
          NavigationLink(value: location) {
            LocationRowView(location: location)
          }
          .listRowSeparator(.visible)
        }
        .listStyle(.plain)
        .refreshable {
          await discoverVM.loadMyLocations(
            name: discoverVM.searchText.isEmpty ? nil : discoverVM.searchText)
        }
        .contentMargins(.horizontal, 12)
        .background(Color.theme.card)
      }
    }
  }
}
