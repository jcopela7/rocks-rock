import Charts
import SwiftUI

struct SendsByGradeView: View {
  @ObservedObject var viewModel: AscentsVM
  var discipline: String
  @State private var selectedGrade: String?

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
        .foregroundStyle(
          selectedGrade == row.gradeValue
            ? Color.theme.accent.opacity(0.6)
            : Color.theme.accent
        )
      }
      .chartXSelection(value: $selectedGrade)
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
      .chartOverlay { proxy in
        GeometryReader { geometry in
          let gradeOrder =
            discipline == "boulder" || discipline == "board"
            ? boulderingGradeOrder : sportGradeOrder
          if let grade = selectedGrade,
            let row = viewModel.ascentsByGrade.first(where: { $0.gradeValue == grade }),
            let idx = gradeOrder.firstIndex(of: grade),
            let plotFrame = proxy.plotFrame.flatMap({ geometry[$0] })
          {
            let n = CGFloat(gradeOrder.count)
            let xCenter = plotFrame.minX + (CGFloat(idx) + 0.5) * (plotFrame.width / n)
            let yCenter = plotFrame.midY
            sendsCountPopover(grade: grade, count: row.totalAscents)
              .position(x: xCenter, y: yCenter)
          }
        }
        .allowsHitTesting(false)
      }
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

  private func sendsCountPopover(grade: String, count: Int) -> some View {
    VStack(spacing: 4) {
      Text(grade)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color.theme.textPrimary)
      Text("\(count) send\(count == 1 ? "" : "s")")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color.theme.background)
    .cornerRadius(10)
    .shadow(color: Color.theme.shadow, radius: 6, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.theme.border, lineWidth: 1)
    )
  }
}

#Preview {
  ContentView()
}
