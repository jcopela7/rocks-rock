import Charts
import SwiftUI

struct SelectableGradeBarChart: View {
  let data: [CountOfAscentsByGradeDTO]
  let xDomain: [String]
  var accentColor: Color = Color.theme.accent
  var frameHeight: CGFloat = 200

  @State private var selectedGrade: String?

  var body: some View {
    Chart(data, id: \.gradeValue) { row in
      BarMark(
        x: .value("Grade", row.gradeValue),
        y: .value("Sends", row.totalAscents)
      )
      .foregroundStyle(
        selectedGrade == nil || selectedGrade == row.gradeValue
          ? accentColor
          : accentColor.opacity(0.6)
      )
    }
    .chartLegend(position: .bottom, alignment: .leading)
    .chartXScale(domain: xDomain)
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
    .frame(height: frameHeight)
    .padding(.horizontal, 8)
    .chartOverlay { proxy in
      GeometryReader { geometry in
        let plotFrame = proxy.plotFrame.flatMap { geometry[$0] }

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
                let hasData = data.contains { $0.gradeValue == pressedGrade }
                selectedGrade = hasData ? pressedGrade : nil
              }
              .onEnded { _ in
                selectedGrade = nil
              }
          )

        if let grade = selectedGrade,
          let row = data.first(where: { $0.gradeValue == grade }),
          let idx = xDomain.firstIndex(of: grade),
          let plotFrame
        {
          let n = CGFloat(xDomain.count)
          let xCenter = plotFrame.minX + (CGFloat(idx) + 0.5) * (plotFrame.width / n)
          let maxTotal = CGFloat(data.map(\.totalAscents).max() ?? 1)
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
