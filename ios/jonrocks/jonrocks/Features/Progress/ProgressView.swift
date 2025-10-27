import SwiftUI
import Charts

struct CragGradeSends: Identifiable, Hashable {
    let id = UUID()
    let crag: String
    let vGrade: String   // e.g., "V2", "V5"
    let sends: Int
}

struct ProgressViewTab: View {
    // Explicitly typed dummy data helps the type-checker
    private let data: [CragGradeSends] = [
        .init(crag: "Squamish", vGrade: "V2", sends: 6),
        .init(crag: "Squamish", vGrade: "V4", sends: 4),
        .init(crag: "Squamish", vGrade: "V6", sends: 2),

        .init(crag: "Hueco",    vGrade: "V2", sends: 3),
        .init(crag: "Hueco",    vGrade: "V4", sends: 5),
        .init(crag: "Hueco",    vGrade: "V6", sends: 4),

        .init(crag: "Bishop",   vGrade: "V2", sends: 2),
        .init(crag: "Bishop",   vGrade: "V4", sends: 3),
        .init(crag: "Bishop",   vGrade: "V6", sends: 5),
    ]

    // Optional: consistent ordering
    private let gradeOrder: [String] = ["V0","V1","V2","V3","V4","V5","V6","V7","V8","V9","V10"]

    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("V-grade Sends by Crag")
                    .font(.headline)

                Chart(data) { row in
                    BarMark(
                        x: .value("Crag", row.crag),
                        y: .value("Sends", row.sends)
                    )
                    .foregroundStyle(by: .value("V-Grade", row.vGrade))
                }
                .chartLegend(position: .bottom, alignment: .leading)
                .chartXAxisLabel("Crag")
                .chartYAxisLabel("Sends")
                .chartForegroundStyleScale([
                    "V2": .blue, "V4": .green, "V6": .orange // optional: simple, stable colors
                ])
                .chartXScale(domain: ["Bishop", "Hueco", "Squamish"]) // optional: order crags
                .chartForegroundStyleScale(domain: gradeOrder)        // optional: order grades
                .frame(height: 280)
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 16)
    }
}

#Preview {
    ContentView()
}

