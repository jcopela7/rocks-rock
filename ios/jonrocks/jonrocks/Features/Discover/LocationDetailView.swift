import Combine
import Foundation
import SwiftUI

struct LocationDetailView: View {
  let location: LocationDTO
  @StateObject private var viewModel: DiscoverVM

  init(location: LocationDTO, authService: AuthenticationService) {
    self.location = location
    _viewModel = StateObject(wrappedValue: DiscoverVM(authService: authService))
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        // Location Description Section
        VStack(alignment: .leading, spacing: 12) {
          Text(location.name)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.theme.accent)

          HStack {
            Text(location.type.capitalized)
              .font(.subheadline)
              .fontWeight(.semibold)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color(.systemGray5))
              .clipShape(Capsule())

            Spacer()
          }

          if let lat = location.latitude, let lon = location.longitude {
            HStack {
              Image(systemName: "mappin.circle.fill")
                .foregroundStyle(.secondary)
              Text(String(format: "%.4f, %.4f", lat, lon))
                .font(.body)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)

        Divider()
          .padding(.horizontal, 16)

        // Routes Section
        VStack(alignment: .leading, spacing: 12) {
          Text("Routes")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal, 16)

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
          } else {
            ForEach(viewModel.routes) { route in
              RouteRowView(route: route)
                .padding(.horizontal, 16)
            }
          }
        }
        .padding(.bottom, 20)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      Task {
        await viewModel.loadFilteredRoutesByLocation(for: location.id)
      }
    }
    .background(Color.theme.background)
  }
}
