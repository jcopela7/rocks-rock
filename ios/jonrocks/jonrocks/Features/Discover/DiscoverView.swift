import SwiftUI

struct DiscoverView: View {
    @StateObject private var discoverVM = DiscoverVM()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "Discover", onAddTap: nil)
                HStack(spacing: 12) {
                    FilterButton(
                        title: "Gym",
                        icon: "figure.climbing",
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
                        icon: "mountain.2",
                        isActive: discoverVM.selectedFilterType == "crag",
                        action: {
                            if discoverVM.selectedFilterType == "crag" {
                                discoverVM.selectedFilterType = nil
                            } else {
                                discoverVM.selectedFilterType = "crag"
                            }
                        }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
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
                    } else if discoverVM.filteredLocations.isEmpty {
                        VStack {
                            Text("No locations available")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(discoverVM.filteredLocations) { location in
                            NavigationLink(destination: LocationDetailView(location: location)) {
                                LocationRowView(location: location)
                            }
                            .listRowSeparator(.visible)
                        }
                        .listStyle(.plain)
                        .contentMargins(.horizontal, 12)
                        .background(Color.theme.card)
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

