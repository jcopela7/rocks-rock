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
        VStack(spacing: 12) {
          Text("No saved locations")
            .font(.headline)
            .foregroundColor(Color.theme.accent)
          Text("Save locations from All Locations to see them here")
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List(discoverVM.filteredMyLocations) { location in
          NavigationLink(value: location) {
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
