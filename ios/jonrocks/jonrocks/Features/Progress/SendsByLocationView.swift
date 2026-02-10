import Charts
import SwiftUI

struct SendsByLocationView: View {
  @ObservedObject var viewModel: AscentsVM

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("Sends by Location")
          .font(.headline)
          .foregroundColor(Color.theme.accent)
        Spacer()
      }
      .padding(.top, 16)
      Chart(viewModel.ascentsByLocationByDiscipline, id: \.locationName) { row in
        BarMark(
          x: .value("Total Sends", row.totalAscents),
          y: .value("Location", row.locationName)
        )
        .foregroundStyle(Color.theme.accent)
        .annotation(position: .trailing) {
          Text("\(row.totalAscents)")
            .font(.caption)
            .foregroundStyle(Color.theme.textPrimary)
        }
      }
      .chartLegend(position: .bottom, alignment: .leading)
      .chartXScale()
      .chartXAxis {
        AxisMarks(values: .automatic) {
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
        }
      }
      .chartYAxis {
        AxisMarks { _ in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
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
