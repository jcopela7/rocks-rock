import SwiftUI

struct BoulderingClimbForm: View {
    @ObservedObject var discoverVM: DiscoverVM
    @ObservedObject var ascentsVM: AscentsVM
    
    @State private var selectedLocationId: UUID? = nil
    @State private var selectedRouteId: UUID? = nil
    @State private var notes: String = ""
    @State private var attempts: Int = 1
    @State private var starts: Int = 0
    @State private var dateClimbed: Date = Date()
    @State private var isSubmitting = false
    @State private var error: String? = nil
    
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
                    Picker("Location", selection: $selectedLocationId) {
                        Text("Select a location").tag(UUID?.none)
                        ForEach(discoverVM.locations, id: \.id) { location in
                            Text(location.name).tag(UUID?.some(location.id))
                        }
                    }
                    .onChange(of: selectedLocationId) {
                        selectedRouteId = nil
                    }
                }
                
                Section("Route") {
                    Picker("Route", selection: $selectedRouteId) {
                        Text("Select a route").tag(UUID?.none)
                        ForEach(filteredRoutes, id: \.id) { route in
                            Text(routeName(for: route)).tag(UUID?.some(route.id))
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
                
                Section("Attempts") {
                    Stepper("Attempts: \(attempts)", value: $attempts, in: 1...100)
                }
                
                Section("Starts") {
                    Stepper("Starts: \(starts)", value: $starts, in: 0...5)
                    Text("Rating based on number of starts")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
            }
            .onAppear {
                Task {
                    await discoverVM.loadLocations()
                    await discoverVM.loadRoutes()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await submitForm()
                        }
                    }
                    .disabled(isSubmitting || selectedLocationId == nil)
                }
            }
        }
    }
    
    private func routeName(for route: RouteDTO) -> String {
        if let name = route.name, !name.isEmpty {
            return "\(name) (\(route.gradeValue))"
        }
        return route.gradeValue
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
                userId: ascentsVM.demoUser,
                routeId: selectedRouteId,
                locationId: locationId,
                style: "attempt",
                attempts: attempts,
                rating: starts > 0 ? starts : nil,
                notes: notes.isEmpty ? nil : notes,
                climbedAt: dateClimbed
            )
            
            let created = try await ascentsVM.api.createAscent(request)
            await MainActor.run {
                ascentsVM.ascents.insert(created, at: 0)
                ascentsVM.error = nil
                
                // Reset form
                selectedLocationId = nil
                selectedRouteId = nil
                notes = ""
                attempts = 1
                starts = 0
                dateClimbed = Date()
            }
        } catch let err {
            await MainActor.run {
                error = err.localizedDescription
            }
        }
    }
}

