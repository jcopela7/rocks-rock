import SwiftUI
import Charts

struct CragGradeSends: Identifiable, Hashable {
    let id = UUID()
    let crag: String
    let vGrade: String   // e.g., "V2", "V5"
    let sends: Int
}

struct ProgressViewTab: View {
    @ObservedObject var viewModel: AscentsVM

    // Optional: consistent ordering
    private let gradeOrder: [String] = ["V0","V1","V2","V3","V4","V5","V6","V7","V8","V9","V10"]

    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                    Text("V-grade Sends (Bouldering)")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)

                    Chart(viewModel.ascentsByGrade, id: \.gradeValue) { row in
                        BarMark(
                            x: .value("Grade", row.gradeValue),
                            y: .value("Sends", row.totalAscents)
                        )
                        .foregroundStyle(Color.theme.accent)
                    }
                    .chartLegend(position: .bottom, alignment: .leading)
                    .chartXAxisLabel("Grade")
                    .chartYAxisLabel("Sends")
                    .chartXScale(domain: gradeOrder)
                    .frame(height: 280)
                    .padding(.top, 8)

                    Spacer()
                }
            .padding(.horizontal, 16)
            .background(Color.raw.slate100)
            .onAppear {
                Task {
                    await viewModel.loadCountOfAscentsByGrade(discipline: "boulder")
                }
            }
    }
}

#Preview {
    ContentView()
}

