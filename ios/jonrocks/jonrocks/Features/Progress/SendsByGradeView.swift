import Charts
import SwiftUI

struct SendsByGradeView: View {
  @ObservedObject var viewModel: AscentsVM
  var discipline: String

  // Optional: consistent ordering
  private let boulderingGradeOrder: [String] = [
    "V0", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10",
  ]
  private let sportGradeOrder: [String] = [
    "5.5", "5.6", "5.7", "5.8", "5.9", "5.10a", "5.10b", "5.10c", "5.11a", "5.11b", "5.11c",
    "5.12a",
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("\(discipline.capitalized) Sends")
          .font(.headline)
          .foregroundColor(Color.theme.accent)
        Spacer()
      }
      .padding(.top, 16)
      HStack(alignment: .center, spacing: 32) {
        ascentMetric(
          label: "Highest Grade", value: "\(viewModel.maxGradeByDiscipline?.maxGrade ?? 0)")
        ascentMetric(
          label: "Total Sends",
          value: "\(viewModel.totalCountOfAscentsByDiscipline?.totalAscents ?? 0)")
      }
      Chart(viewModel.ascentsByGrade, id: \.gradeValue) { row in
        BarMark(
          x: .value("Grade", row.gradeValue),
          y: .value("Sends", row.totalAscents)
        )
        .foregroundStyle(Color.theme.accent)
      }
      .chartLegend(position: .bottom, alignment: .leading)
      .chartXScale(
        domain: discipline == "boulder" || discipline == "board"
          ? boulderingGradeOrder : sportGradeOrder
      )
      .chartXAxis {
        AxisMarks { value in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
          AxisTick()
          AxisValueLabel {
            Text(value.as(String.self) ?? "")
              .rotationEffect(Angle(degrees: -45))
          }
        }
      }
      .chartYAxis {
        AxisMarks(values: .automatic) {
          AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
          AxisTick()
          AxisValueLabel()
            .foregroundStyle(Color.theme.textPrimary)
        }
      }
      .frame(height: 200)
      .padding(.horizontal, 8)
      Spacer()
    }
    .padding(.horizontal, 16)
    .background(.white)
    .cornerRadius(32)
    .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 32)
        .stroke(Color.theme.border, lineWidth: 1)
    )

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
