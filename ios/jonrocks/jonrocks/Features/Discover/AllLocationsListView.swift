import SwiftUI

struct AllLocationsListView: View {
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
