import Combine
import Foundation
import SwiftUI

struct LocationDetailView: View {
  let location: LocationDTO
  @StateObject private var viewModel: DiscoverVM
  @State private var routeSearchText = ""

  private var filteredRoutes: [RouteDTO] {
    if routeSearchText.isEmpty {
      return viewModel.routes
    }
    let query = routeSearchText.lowercased()
    return viewModel.routes.filter { route in
      let name = (route.name ?? "Unnamed").lowercased()
      let grade = route.gradeValue.lowercased()
      return name.contains(query) || grade.contains(query)
    }
  }

  init(location: LocationDTO, authService: AuthenticationService) {
    self.location = location
    _viewModel = StateObject(wrappedValue: DiscoverVM(authService: authService))
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        // Location Description Section
        VStack(alignment: .leading) {
          Text(location.name)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.theme.accent)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
          Text(location.description ?? "")
            .font(.body)
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
          Rectangle()
            .fill(Color.raw.slate200)
            .frame(height: 1)
        }
        .background(Color.white)
        // Routes Section
        VStack(alignment: .leading, spacing: 12) {
          Text("Routes")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal, 16)
            .padding(.top, 16)
          SearchBar(text: $routeSearchText, placeholder: "Search routes...")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
          if viewModel.loading {
            LoadingListView()
          } else if let error = viewModel.error {
            VStack {
              Text("Error loading routes")
                .font(.headline)
              Text(error)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
          } else if viewModel.routes.isEmpty {
            VStack {
              Text("No routes available at this location")
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
          } else if filteredRoutes.isEmpty {
            VStack {
              Text("No routes found")
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
          } else {
            ForEach(filteredRoutes) { route in
              NavigationLink(destination: RouteDetailView(route: route)) {
                RouteRowView(route: route)
              }
              .buttonStyle(.plain)
              .padding(.horizontal, 16)
            }
          }
        }
        .padding(.bottom, 20)
        .background(Color.theme.background)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(location.name)
    .background(Color.white)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          Task {
            await viewModel.toggleFavourite(locationId: location.id)
          }
        } label: {
          if viewModel.favouriteLoading {
            ProgressView()
          } else {
            Image(systemName: viewModel.isLocationFavourite ? "heart.fill" : "heart")
              .foregroundColor(viewModel.isLocationFavourite ? .red : Color.theme.accent)
          }
        }
        .disabled(viewModel.favouriteLoading)
      }
    }
    .onAppear {
      Task {
        await viewModel.loadFilteredRoutesByLocation(for: location.id)
        await viewModel.loadFavouriteStatus(for: location.id)
      }
    }

  }
}
