import SwiftUI

struct BoulderingClimbForm: View {
  @ObservedObject var discoverVM: DiscoverVM
  @ObservedObject var ascentsVM: AscentsVM

  @State private var selectedLocationId: UUID? = nil
  @State private var selectedRouteId: UUID? = nil
  @State private var notes: String = ""
  @State private var attempts: Int = 1
  @State private var stars: Int = 0
  @State private var dateClimbed: Date = .init()
  @State private var isSubmitting = false
  @State private var error: String? = nil
  @State private var showingSearchModal = false

  var filteredRoutes: [RouteDTO] {
    let boulderRoutes = discoverVM.routes.filter { $0.discipline == "boulder" }
    guard let locationId = selectedLocationId else {
      return boulderRoutes
    }
    return boulderRoutes.filter { $0.locationId == locationId }
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Location") {
          Button(action: {
            showingSearchModal = true
          }) {
            HStack {
              Text(selectedLocationName)
                .foregroundColor(selectedLocationId == nil ? .secondary : .primary)
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
            }
          }
          .onChange(of: selectedLocationId) {
            selectedRouteId = nil
          }
        }

        Section("Route") {
          Button(action: {
            showingSearchModal = true
          }) {
            HStack {
              Text(selectedRouteName)
                .foregroundColor(selectedRouteId == nil ? .secondary : .primary)
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
            }
          }
          .disabled(selectedLocationId == nil)
        }

        Section("Notes") {
          TextEditor(text: $notes)
            .frame(minHeight: 80)
        }

        Section("Attempts") {
          Stepper("Attempts: \(attempts)", value: $attempts, in: 1...100)
        }

        Section("Stars") {
          Stepper("Stars: \(stars)", value: $stars, in: 0...5)
        }

        Section("Date Climbed") {
          DatePicker("Date Climbed", selection: $dateClimbed, displayedComponents: [.date])
        }

        if let error = error {
          Section {
            Text(error)
              .foregroundColor(.red)
          }
        }

        Section {
          Button(action: {
            Task { await submitForm() }
          }) {
            Text("Save")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background(Color.theme.accent)
              .foregroundColor(.white)
              .font(.headline)
              .cornerRadius(4)
              .contentShape(Rectangle())
          }
          .disabled(isSubmitting || selectedLocationId == nil)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
      }
      .listStyle(.plain)
      .sheet(isPresented: $showingSearchModal) {
        LocationRouteSearchModal(
          discoverVM: discoverVM,
          selectedLocationId: $selectedLocationId,
          selectedRouteId: $selectedRouteId,
          isPresented: $showingSearchModal,
          filteredRoutes: filteredRoutes,
          routeNameFormatter: routeName(for:)
        )
      }
      .onAppear {
        Task {
          await discoverVM.loadLocations()
          await discoverVM.loadRoutes()
        }
      }
    }
  }

  private var selectedLocationName: String {
    guard let locationId = selectedLocationId,
      let location = discoverVM.locations.first(where: { $0.id == locationId })
    else {
      return "Select a location"
    }
    return location.name
  }

  private var selectedRouteName: String {
    guard let routeId = selectedRouteId,
      let route = filteredRoutes.first(where: { $0.id == routeId })
    else {
      return "Select a route"
    }
    return routeName(for: route)
  }

  private func routeName(for route: RouteDTO) -> String {
    if let name = route.name, !name.isEmpty {
      return "\(name) (\(route.gradeValue))"
    }
    return route.gradeValue
  }

  private func clearForm() {
    selectedLocationId = nil
    selectedRouteId = nil
    notes = ""
    attempts = 1
    stars = 0
    dateClimbed = Date()
    error = nil
  }

  private func submitForm() async {
    isSubmitting = true
    defer { isSubmitting = false }

    error = nil

    guard let locationId = selectedLocationId else {
      error = "Please select a location"
      return
    }

    do {
      let request = CreateAscentRequest(
        routeId: selectedRouteId,
        locationId: locationId,
        style: "attempt",
        attempts: attempts,
        rating: stars > 0 ? stars : nil,
        notes: notes.isEmpty ? nil : notes,
        climbedAt: dateClimbed
      )

      let created = try await ascentsVM.api.createAscent(request)
      await MainActor.run {
        ascentsVM.ascents.insert(created, at: 0)
        ascentsVM.error = nil
        clearForm()
      }
    } catch let err {
      await MainActor.run {
        error = err.localizedDescription
      }
    }
  }
}
