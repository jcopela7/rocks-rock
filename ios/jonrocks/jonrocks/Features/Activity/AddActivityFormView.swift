import SwiftUI

struct AddActivityFormView: View {
    @ObservedObject var viewModel: AscentsVM
    @Environment(\.dismiss) private var dismiss

    @State private var formData = AscentFormData()
    @State private var isSubmitting = false

    private let styleOptions = ["attempt", "send", "flash", "onsight", "redpoint"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    Picker("Route", selection: $formData.routeId) {
                        Text("None").tag(UUID?.none)
                        ForEach(viewModel.routes, id: \.id) { route in
                            Text(routeName(for: route)).tag(UUID?.some(route.id))
                        }
                    }
                }
                
                Section("Climb Details") {
                    Picker("Style", selection: $formData.style) {
                        ForEach(styleOptions, id: \.self) { style in
                            Text(style.capitalized).tag(style)
                        }
                    }

                    Stepper("Attempts: \(formData.attempts)", value: $formData.attempts, in: 1 ... 20)
                }

                Section("Location") {
                    Toggle("Outdoor Climbing", isOn: $formData.isOutdoor)
                }

                Section("Rating") {
                    TextField("Grade (e.g., 5.10a, V4)", text: $formData.rating)
                        .textInputAutocapitalization(.never)
                }

                Section("Notes") {
                    TextEditor(text: $formData.notes)
                        .frame(minHeight: 80)
                }

                Section("Date") {
                    DatePicker("Climb Date", selection: $formData.climbedAt, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Ascent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await submitForm()
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
        }
        .task {
            await viewModel.loadRoutes()
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

        do {
            let request = formData.createAscentRequest
            let created = try await viewModel.api.createAscent(request)
            await MainActor.run {
                viewModel.ascents.insert(created, at: 0)
                viewModel.error = nil
                dismiss()
            }
        } catch {
            await MainActor.run {
                viewModel.error = error.localizedDescription
            }
        }
    }
}
