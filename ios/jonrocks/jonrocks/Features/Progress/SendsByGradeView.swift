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
          selectedGrade == nil || selectedGrade == row.gradeValue
            ? Color.theme.accent
            : Color.theme.accent.opacity(0.6)
        )
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
      .chartOverlay { proxy in
        GeometryReader { geometry in
          let plotFrame = proxy.plotFrame.flatMap { geometry[$0] }
          let gradeOrder =
            discipline == "boulder" || discipline == "board"
            ? boulderingGradeOrder : sportGradeOrder

          Color.clear
            .contentShape(Rectangle())
            .gesture(
              DragGesture(minimumDistance: 0)
                .onChanged { value in
                  guard let plotFrame else { return }
                  let xInPlot = value.location.x - plotFrame.minX
                  guard let pressedGrade = proxy.value(atX: xInPlot, as: String.self) else {
                    selectedGrade = nil
                    return
                  }
                  let hasData = viewModel.ascentsByGrade.contains { $0.gradeValue == pressedGrade }
                  selectedGrade = hasData ? pressedGrade : nil
                }
                .onEnded { _ in
                  selectedGrade = nil
                }
            )

          if let grade = selectedGrade,
            let row = viewModel.ascentsByGrade.first(where: { $0.gradeValue == grade }),
            let idx = gradeOrder.firstIndex(of: grade),
            let plotFrame
          {
            let n = CGFloat(gradeOrder.count)
            let xCenter = plotFrame.minX + (CGFloat(idx) + 0.5) * (plotFrame.width / n)
            let maxTotal = CGFloat(viewModel.ascentsByGrade.map(\.totalAscents).max() ?? 1)
            let topOfBar =
              plotFrame.maxY - (CGFloat(row.totalAscents) / maxTotal) * plotFrame.height
            let popoverHeight: CGFloat = 44
            let connectorHeight = max(0, topOfBar - plotFrame.minY - popoverHeight)
            sendsCountPopoverWithConnector(
              grade: grade, count: row.totalAscents, connectorHeight: connectorHeight
            )
            .position(x: xCenter, y: topOfBar - connectorHeight / 2 - popoverHeight / 2)
            .allowsHitTesting(false)
          }
        }
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

  private func sendsCountPopoverWithConnector(
    grade: String, count: Int, connectorHeight: CGFloat
  ) -> some View {
    VStack(spacing: 0) {
      sendsCountPopover(grade: grade, count: count)
      Rectangle()
        .fill(Color.theme.border)
        .frame(width: 2, height: connectorHeight - 8)
    }
  }
}

#Preview {
  ContentView()
}
