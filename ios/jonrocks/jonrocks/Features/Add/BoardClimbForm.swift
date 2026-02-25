import SwiftUI

private let vGrades: [(value: String, rank: Int)] = [
  ("VB", 0), ("V0", 1), ("V1", 2), ("V2", 3), ("V3", 4),
  ("V4", 5), ("V5", 6), ("V6", 7), ("V7", 8), ("V8", 9),
  ("V9", 10), ("V10", 11), ("V11", 12), ("V12", 13), ("V13", 14),
  ("V14", 15), ("V15", 16), ("V16", 17), ("V17", 18),
]

struct BoardClimbForm: View {
  @ObservedObject var ascentsVM: AscentsVM

  var onClose: (() -> Void)?

  @State private var boardLocations: [LocationDTO] = []
  @State private var selectedLocationId: UUID? = nil
  @State private var climbName: String = ""
  @State private var selectedGradeIndex: Int = 0
  @State private var notes: String = ""
  @State private var attempts: Int = 1
  @State private var stars: Int = 0
  @State private var dateClimbed: Date = .init()
  @State private var isSubmitting = false
  @State private var isLoadingLocations = false
  @State private var error: String? = nil

  private let attemptsRange = 1...100
  private let starsRange = 0...5

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 18) {
            sectionHeader("Activity Type")
            HStack(spacing: 10) {
              Image("boardIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.theme.textSecondary)
              Text("Board")
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
              Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .formFieldCard()

            Divider()

            sectionHeader("Climb Details")

            boardPicker

            VStack(alignment: .leading, spacing: 8) {
              Label("Climb Name (optional)", systemImage: "pencil")
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
              TextField("e.g. The Pinch", text: $climbName)
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
            }
            .padding(12)
            .formFieldCard()

            gradePicker

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
      .onAppear {
        Task { await loadBoardLocations() }
      }
    }
  }

  // MARK: Subviews

  private var boardPicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Board", systemImage: "mappin.and.ellipse")
        .font(.subheadline)
        .foregroundColor(Color.theme.textSecondary)
      if isLoadingLocations {
        ProgressView()
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.vertical, 8)
      } else {
        Picker("Board", selection: $selectedLocationId) {
          Text("Select a board").tag(UUID?(nil))
          ForEach(boardLocations) { loc in
            Text(loc.name).tag(Optional(loc.id))
          }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(12)
    .formFieldCard()
  }

  private var gradePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label("Grade", systemImage: "chart.bar.fill")
        .font(.subheadline)
        .foregroundColor(Color.theme.textSecondary)
      Picker("Grade", selection: $selectedGradeIndex) {
        ForEach(vGrades.indices, id: \.self) { i in
          Text(vGrades[i].value).tag(i)
        }
      }
      .pickerStyle(.wheel)
      .frame(height: 150)
      .clipped()
    }
    .padding(12)
    .formFieldCard()
  }

  private func sectionHeader(_ text: String) -> some View {
    Text(text)
      .font(.subheadline)
      .fontWeight(.semibold)
      .foregroundColor(Color.theme.textPrimary)
      .padding(.horizontal, 4)
  }

  // MARK: Actions

  private func loadBoardLocations() async {
    isLoadingLocations = true
    defer { isLoadingLocations = false }
    do {
      boardLocations = try await ascentsVM.api.listLocations(type: "board")
    } catch {
      self.error = "Failed to load boards: \(error.localizedDescription)"
    }
  }

  private func clearForm() {
    selectedLocationId = nil
    climbName = ""
    selectedGradeIndex = 0
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
      error = "Please select a board"
      return
    }

    let grade = vGrades[selectedGradeIndex]

    do {
      var request = CreateAscentRequest(
        routeId: nil,
        locationId: locationId,
        style: "attempt",
        attempts: attempts,
        rating: stars > 0 ? stars : nil,
        notes: notes.isEmpty ? nil : notes,
        climbedAt: dateClimbed
      )
      request.customClimbName = climbName.isEmpty ? nil : climbName
      request.customGradeValue = grade.value
      request.customGradeRank = grade.rank
      request.customDiscipline = "board"

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

#Preview {
  BoardClimbForm(ascentsVM: AscentsVM(authService: AuthenticationService()))
}
