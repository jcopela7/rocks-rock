import Charts
import SwiftUI

struct SendsByGradeView: View {
    @ObservedObject var viewModel: AscentsVM

    // Optional: consistent ordering
    private let gradeOrder: [String] = ["V0", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("V-grade Sends (Bouldering)")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                Spacer()
            }
            .padding(.top, 16)
            HStack(alignment: .center, spacing: 32) {
                ascentMetric(label: "Highest Grade", value: "V10")
                ascentMetric(label: "Total Sends", value: "62")
            }
            Chart(viewModel.ascentsByGrade, id: \.gradeValue) { row in
                BarMark(
                    x: .value("Grade", row.gradeValue),
                    y: .value("Sends", row.totalAscents)
                )
                .foregroundStyle(Color.theme.accent)
            }
            .chartLegend(position: .bottom, alignment: .leading)
            .chartYAxisLabel("Sends")
            .chartXScale(domain: gradeOrder)
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 280)
            .padding(.horizontal, 8)
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(.white)
        .onAppear {
            Task {
                await viewModel.loadCountOfAscentsByGrade(discipline: "boulder")
            }
        }
    }

    private func ascentMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .foregroundStyle(Color.theme.textPrimary)
        }
    }
}

#Preview {
    ContentView()
}
