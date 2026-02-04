import Charts
import SwiftUI

struct ProgressViewTab: View {
  @ObservedObject var viewModel: AscentsVM

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        ClimbingCalendarView(month: Date(), ascents: viewModel.ascents)
        SendsByGradeView(viewModel: viewModel, discipline: "boulder")
        SendsByLocationView(viewModel: viewModel)
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
    }
    .background(Color.raw.slate100)
    .task {
      await viewModel.loadAscents()
      await viewModel.loadCountOfAscentsByGrade(discipline: "boulder")
      await viewModel.loadCountOfAscentsGroupByLocation()
      await viewModel.loadMaxGradeByDiscipline(discipline: "boulder")
      await viewModel.loadTotalCountOfAscentsByDiscipline(discipline: "boulder")
    }
    .refreshable {
      await viewModel.loadAscents()
      await viewModel.loadCountOfAscentsByGrade(discipline: "boulder")
      await viewModel.loadCountOfAscentsGroupByLocation()
      await viewModel.loadMaxGradeByDiscipline(discipline: "boulder")
      await viewModel.loadTotalCountOfAscentsByDiscipline(discipline: "boulder")
    }
  }
}

#Preview {
  ContentView()
}
