import Charts
import SwiftUI

private let progressDisciplineOptions: [(id: String, label: String, icon: String)] = [
  ("boulder", "Boulder", "crashpadIcon"),
  ("sport", "Sport", "quickdrawIcon"),
  ("trad", "Trad", "camIcon"),
  ("board", "Board", "boardIcon"),
]

struct ProgressViewTab: View {
  @ObservedObject var viewModel: AscentsVM
  @State private var selectedDiscipline: String = "boulder"

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        disciplineFilterRow
        ClimbingCalendarView(
          month: Date(),
          ascents: viewModel.ascents.filter {
            $0.routeDiscipline?.lowercased() == selectedDiscipline.lowercased()
          }
        )
        SendsByGradeView(viewModel: viewModel, discipline: selectedDiscipline)
        SendsByLocationView(viewModel: viewModel)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 16)
    }
    .background(Color.raw.slate100)
    .task {
      await viewModel.loadAscents()
      await loadDisciplineData()
    }
    .refreshable {
      await viewModel.loadAscents()
      await loadDisciplineData()
    }
    .onChange(of: selectedDiscipline) { _, _ in
      Task { await loadDisciplineData() }
    }
  }

  private var disciplineFilterRow: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(progressDisciplineOptions, id: \.id) { option in
          FilterButton(
            title: option.label,
            icon: option.icon,
            isActive: selectedDiscipline == option.id,
            action: { selectedDiscipline = option.id }
          )
        }
      }
      .padding(.vertical, 4)
    }
  }

  private func loadDisciplineData() async {
    await viewModel.loadCountOfAscentsByGrade(discipline: selectedDiscipline)
    await viewModel.loadMaxGradeByDiscipline(discipline: selectedDiscipline)
    await viewModel.loadTotalCountOfAscentsByDiscipline(discipline: selectedDiscipline)
    await viewModel.loadCountOfAscentsGroupByLocation(discipline: selectedDiscipline)

  }
}

#Preview {
  ContentView()
}
