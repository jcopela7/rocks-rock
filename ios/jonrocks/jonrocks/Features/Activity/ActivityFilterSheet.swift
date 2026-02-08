//
//  ActivityFilterSheet.swift
//  jonrocks
//
import SwiftUI

struct ActivityFilterSheet: View {
  @ObservedObject var ascentsVM: AscentsVM
  @Environment(\.dismiss) private var dismiss

  private var availableGrades: [String] {
    let source = ascentsVM.ascents
    let filtered: [AscentDTO]
    if let discipline = ascentsVM.filterDiscipline {
      filtered = source.filter { $0.routeDiscipline?.lowercased() == discipline.lowercased() }
    } else {
      filtered = source
    }
    let grades = Set(filtered.compactMap(\.routeGradeValue)).filter { !$0.isEmpty }
    return grades.sorted { a, b in
      (filtered.first(where: { $0.routeGradeValue == a })?.routeGradeRank ?? 0)
        < (filtered.first(where: { $0.routeGradeValue == b })?.routeGradeRank ?? 0)
    }
  }

  private static let calendar = Calendar.current
  private static var defaultMinDate: Date {
    calendar.date(from: calendar.dateComponents([.year], from: Date())) ?? Date()
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Discipline") {
          Picker("Discipline", selection: $ascentsVM.filterDiscipline) {
            Text("All").tag(nil as String?)
            Text("Boulder").tag("boulder" as String?)
            Text("Sport").tag("sport" as String?)
            Text("Trad").tag("trad" as String?)
            Text("Board").tag("board" as String?)
          }
          .pickerStyle(.menu)
        }

        Section("Grade") {
          Picker("Grade", selection: $ascentsVM.filterGrade) {
            Text("All").tag(nil as String?)
            ForEach(availableGrades, id: \.self) { grade in
              Text(grade).tag(grade as String?)
            }
          }
          .pickerStyle(.menu)
        }

        Section("Date range") {
          HStack {
            DatePicker(
              "From",
              selection: Binding(
                get: { ascentsVM.filterMinDate ?? Self.defaultMinDate },
                set: { ascentsVM.filterMinDate = $0 }
              ),
              displayedComponents: [.date]
            )
            if ascentsVM.filterMinDate != nil {
              Button("Clear") {
                ascentsVM.filterMinDate = nil
              }
              .foregroundColor(Color.theme.accent)
            }
          }
          HStack {
            DatePicker(
              "To",
              selection: Binding(
                get: { ascentsVM.filterMaxDate ?? Date() },
                set: { ascentsVM.filterMaxDate = $0 }
              ),
              displayedComponents: [.date]
            )
            if ascentsVM.filterMaxDate != nil {
              Button("Clear") {
                ascentsVM.filterMaxDate = nil
              }
              .foregroundColor(Color.theme.accent)
            }
          }
        }

        Section {
          Button("Clear all filters") {
            ascentsVM.filterDiscipline = nil
            ascentsVM.filterGrade = nil
            ascentsVM.filterMinDate = nil
            ascentsVM.filterMaxDate = nil
          }
          .foregroundColor(Color.theme.accent)
          .frame(maxWidth: .infinity)
        }
      }
      .scrollContentBackground(.hidden)
      .background(Color.raw.slate100)
      .foregroundColor(Color.theme.textPrimary)
      .navigationTitle("Filter")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
          .foregroundColor(Color.theme.accent)
        }
      }
    }
  }
}

#Preview {
  ActivityFilterSheet(ascentsVM: AscentsVM(authService: AuthenticationService()))
}
