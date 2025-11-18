import SwiftUI

struct DiscoverView: View {
    @StateObject private var discoverVM = DiscoverVM()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "Discover", onAddTap: nil)
                
                Group {
                    if discoverVM.loading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = discoverVM.error {
                        VStack {
                            Text("Error loading locations")
                                .font(.headline)
                            Text(error)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if discoverVM.locations.isEmpty {
                        VStack {
                            Text("No locations available")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(discoverVM.locations) { location in
                            LocationRowView(location: location)
                                .listRowSeparator(.visible)
                        }
                        .listStyle(.plain)
                        .contentMargins(.horizontal, 12)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .task {
                await discoverVM.loadLocations()
            }
        }
    }
}

struct LocationRowView: View {
    let location: LocationDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                Spacer()
                Text(location.type.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            
            if let lat = location.latitude, let lon = location.longitude {
                Text(String(format: "%.4f, %.4f", lat, lon))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DiscoverView()
}

