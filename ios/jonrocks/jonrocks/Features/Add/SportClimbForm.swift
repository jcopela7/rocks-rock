import SwiftUI

struct SportClimbForm: View {
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
    let sportRoutes = discoverVM.routes.filter { $0.discipline == "sport" }
    guard let locationId = selectedLocationId else {
      return sportRoutes
    }
    return sportRoutes.filter { $0.locationId == locationId }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          sectionHeader("Location")
          selectionField(
            icon: "mappin.and.ellipse",
            text: selectedLocationName,
            isPlaceholder: selectedLocationId == nil
          ) {
            showingSearchModal = true
          }
          .onChange(of: selectedLocationId) {
            selectedRouteId = nil
          }

          sectionHeader("Route")
          selectionField(
            icon: "figure.climbing",
            text: selectedRouteName,
            isPlaceholder: selectedRouteId == nil
          ) {
            showingSearchModal = true
          }
          .disabled(selectedLocationId == nil)

          sectionHeader("Notes")
          VStack(alignment: .leading, spacing: 8) {
            Label("Private notes", systemImage: "note.text")
              .font(.subheadline)
              .foregroundColor(Color.theme.textSecondary)
            TextEditor(text: $notes)
              .frame(minHeight: 88)
              .scrollContentBackground(.hidden)
          }
          .padding(12)
          .formFieldCard()

          sectionHeader("Attempts")
          HStack(spacing: 10) {
            Image(systemName: "number")
              .foregroundColor(Color.theme.textSecondary)
            Stepper("Attempts: \(attempts)", value: $attempts, in: 1...100)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          sectionHeader("Stars")
          HStack(spacing: 10) {
            Image(systemName: "star")
              .foregroundColor(Color.theme.textSecondary)
            Stepper("Stars: \(stars)", value: $stars, in: 0...5)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          sectionHeader("Date Climbed")
          DatePicker(selection: $dateClimbed, displayedComponents: [.date]) {
            Label("Date Climbed", systemImage: "calendar")
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          if let error = error {
            Text(error)
              .font(.footnote)
              .foregroundColor(Color.theme.danger)
              .padding(.horizontal, 4)
          }

          Button(action: {
            Task { await submitForm() }
          }) {
            Text(isSubmitting ? "Saving..." : "Save")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .background(Color.theme.accent)
              .foregroundColor(.white)
              .font(.headline)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .contentShape(Rectangle())
          }
          .disabled(isSubmitting || selectedLocationId == nil)
          .opacity((isSubmitting || selectedLocationId == nil) ? 0.6 : 1)
        }
        .padding(16)
      }
      .background(Color.white)
      .foregroundColor(Color.theme.textPrimary)
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

  private func sectionHeader(_ text: String) -> some View {
    Text(text)
      .font(.subheadline)
      .fontWeight(.semibold)
      .foregroundColor(Color.theme.textPrimary)
      .padding(.horizontal, 4)
  }

  private func selectionField(
    icon: String,
    text: String,
    isPlaceholder: Bool,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(Color.theme.textSecondary)
        Text(text)
          .foregroundColor(isPlaceholder ? Color.theme.textSecondary : Color.theme.textPrimary)
        Spacer()
        Image(systemName: "chevron.down")
          .font(.system(size: 13, weight: .semibold))
          .foregroundColor(Color.theme.textSecondary)
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 14)
      .formFieldCard()
    }
    .buttonStyle(.plain)
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
