import SwiftUI

struct SportClimbForm: View {
  @ObservedObject var discoverVM: DiscoverVM
  @ObservedObject var ascentsVM: AscentsVM

  var onClose: (() -> Void)?

  @State private var selectedLocationId: UUID? = nil
  @State private var selectedRouteId: UUID? = nil
  @State private var notes: String = ""
  @State private var attempts: Int = 1
  @State private var stars: Int = 0
  @State private var dateClimbed: Date = .init()
  @State private var isSubmitting = false
  @State private var error: String? = nil
  @State private var showingSearchModal = false
  private let attemptsRange = 1...100
  private let starsRange = 0...5

  var filteredRoutes: [RouteDTO] {
    let sportRoutes = discoverVM.routes.filter { $0.discipline == "sport" }
    guard let locationId = selectedLocationId else {
      return sportRoutes
    }
    return sportRoutes.filter { $0.locationId == locationId }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            sectionHeader("Activity Type")
            HStack(spacing: 10) {
              Image("quickdrawIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.theme.textSecondary)
              Text("Sport Climbing")
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
              Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .formFieldCard()

            Divider()

            sectionHeader("Climb Details")
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
            selectionField(
              icon: "figure.climbing",
              text: selectedRouteName,
              isPlaceholder: selectedRouteId == nil
            ) {
              showingSearchModal = true
            }
            .disabled(selectedLocationId == nil)

            Divider()

            sectionHeader("Metadata")
            VStack(alignment: .leading, spacing: 8) {
              Label("Notes", systemImage: "note.text")
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
              TextEditor(text: $notes)
                .frame(minHeight: 88)
                .scrollContentBackground(.hidden)
            }
            .padding(12)
            .formFieldCard()

            Divider()

            sectionHeader("Activity Details")
            HStack(spacing: 10) {
              Image(systemName: "number")
                .foregroundColor(Color.theme.textSecondary)
              Text("Attempts: \(attempts)")
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
              Spacer()
              HStack(spacing: 8) {
                StepperAdjustButton(
                  symbol: "minus",
                  action: { attempts = max(attemptsRange.lowerBound, attempts - 1) },
                  isDisabled: attempts <= attemptsRange.lowerBound
                )
                StepperAdjustButton(
                  symbol: "plus",
                  action: { attempts = min(attemptsRange.upperBound, attempts + 1) },
                  isDisabled: attempts >= attemptsRange.upperBound
                )
              }
              .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .formFieldCard()
            VStack(alignment: .leading, spacing: 10) {
              HStack(spacing: 10) {
                Image(systemName: "star")
                  .foregroundColor(Color.theme.textSecondary)
                Text("Stars: ")
                  .font(.subheadline)
                  .foregroundColor(Color.theme.textPrimary)
                if stars > 0 {
                  HStack(spacing: 2) {
                    ForEach(0..<stars, id: \.self) { _ in
                      Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    }
                  }
                } else {
                  Text("No stars")
                    .font(.footnote)
                    .foregroundColor(Color.theme.textSecondary)
                }
                Spacer()
                HStack(spacing: 8) {
                  StepperAdjustButton(
                    symbol: "minus",
                    action: { stars = max(starsRange.lowerBound, stars - 1) },
                    isDisabled: stars <= starsRange.lowerBound
                  )
                  StepperAdjustButton(
                    symbol: "plus",
                    action: { stars = min(starsRange.upperBound, stars + 1) },
                    isDisabled: stars >= starsRange.upperBound
                  )
                }
                .buttonStyle(.plain)
              }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .formFieldCard()

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
          }
          .padding(16)
        }
        .background(Color.white)

        let isDisabled = isSubmitting || selectedLocationId == nil
        VStack(spacing: 0) {
          Divider()
          Button(action: {
            Task { await submitForm() }
          }) {
            Text(isSubmitting ? "Saving..." : "Save")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .font(.headline)
              .foregroundColor(isDisabled ? Color(UIColor.darkGray) : .white)
              .background(isDisabled ? Color(UIColor.systemGray4) : Color.theme.accent)
              .clipShape(RoundedRectangle(cornerRadius: 10))
          }
          .disabled(isDisabled)
          .padding(16)
        }
        .footerShadow()
        .background(Color.white)
      }
      .foregroundColor(Color.theme.textPrimary)
      .sheet(isPresented: $showingSearchModal) {
        LocationRouteSearchModal(
          discoverVM: discoverVM,
          selectedLocationId: $selectedLocationId,
          type: "crag",
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
        onClose?()
      }
    } catch let err {
      await MainActor.run {
        error = err.localizedDescription
      }
    }
  }
}
