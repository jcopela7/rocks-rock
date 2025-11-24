import Charts
import SwiftUI

struct ProgressViewTab: View {
    @ObservedObject var viewModel: AscentsVM

    // Optional: consistent ordering
    private let gradeOrder: [String] = ["V0", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                SendsByGradeView(viewModel: viewModel, discipline: "boulder")
                SendsByGradeView(viewModel: viewModel, discipline: "sport")
                SendsByGradeView(viewModel: viewModel, discipline: "trad")
                SendsByGradeView(viewModel: viewModel, discipline: "board")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.raw.slate100)
        .task {
            await viewModel.loadCountOfAscentsByGrade(discipline: "boulder")
            await viewModel.loadCountOfAscentsByGrade(discipline: "sport")
            await viewModel.loadCountOfAscentsByGrade(discipline: "trad")
            await viewModel.loadCountOfAscentsByGrade(discipline: "board")
        }
        .refreshable {
            await viewModel.loadCountOfAscentsByGrade(discipline: "boulder")
            await viewModel.loadCountOfAscentsByGrade(discipline: "sport")
            await viewModel.loadCountOfAscentsByGrade(discipline: "trad")
            await viewModel.loadCountOfAscentsByGrade(discipline: "board")
        }
    }
}

#Preview {
    ContentView()
}
