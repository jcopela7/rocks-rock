import SwiftUI

struct AddActivityFormView: View {
  @ObservedObject var ascentsVM: AscentsVM
  @ObservedObject var discoverVM: DiscoverVM
  @Environment(\.dismiss) private var dismiss

  @State private var formData = AscentFormData()
  @State private var isSubmitting = false

  private let styleOptions = ["attempt", "send", "flash", "onsight", "redpoint"]

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          sectionHeader("Route")
          HStack(spacing: 10) {
            Image(systemName: "figure.climbing")
              .foregroundColor(Color.theme.textSecondary)
            Picker("Route", selection: $formData.routeId) {
              Text("None").tag(UUID?.none)
              ForEach(discoverVM.routes, id: \.id) { route in
                Text(routeName(for: route)).tag(UUID?.some(route.id))
              }
            }
            .pickerStyle(.menu)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          sectionHeader("Style")
          HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.branch")
              .foregroundColor(Color.theme.textSecondary)
            Picker("Style", selection: $formData.style) {
              ForEach(styleOptions, id: \.self) { style in
                Text(style.capitalized).tag(style)
              }
            }
            .pickerStyle(.menu)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          sectionHeader("Attempts")
          HStack(spacing: 10) {
            Image(systemName: "number")
              .foregroundColor(Color.theme.textSecondary)
            Stepper("Attempts: \(formData.attempts)", value: $formData.attempts, in: 1...20)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          sectionHeader("Rating")
          HStack(spacing: 10) {
            Image(systemName: "chart.bar")
              .foregroundColor(Color.theme.textSecondary)
            TextField("Grade (e.g., 5.10a, V4)", text: $formData.rating)
              .textInputAutocapitalization(.never)
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()

          sectionHeader("Notes")
          VStack(alignment: .leading, spacing: 8) {
            Label("Private notes", systemImage: "note.text")
              .font(.subheadline)
              .foregroundColor(Color.theme.textSecondary)
            TextEditor(text: $formData.notes)
              .frame(minHeight: 88)
              .scrollContentBackground(.hidden)
          }
          .padding(12)
          .formFieldCard()

          sectionHeader("Date")
          DatePicker(selection: $formData.climbedAt, displayedComponents: [.date, .hourAndMinute]) {
            Label("Climb Date", systemImage: "calendar")
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 14)
          .formFieldCard()
        }
        .padding(16)
      }
      .background(Color.white)
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
      await discoverVM.loadRoutes()
    }
  }

  private func sectionHeader(_ text: String) -> some View {
    Text(text)
      .font(.subheadline)
      .fontWeight(.semibold)
      .foregroundColor(Color.theme.textPrimary)
      .padding(.horizontal, 4)
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
      let created = try await ascentsVM.api.createAscent(request)
      await MainActor.run {
        ascentsVM.ascents.insert(created, at: 0)
        ascentsVM.error = nil
        dismiss()
      }
    } catch {
      await MainActor.run {
        ascentsVM.error = error.localizedDescription
      }
    }
  }
}
