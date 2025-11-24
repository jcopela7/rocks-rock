import Charts
import SwiftUI

struct ProgressViewTab: View {
    @ObservedObject var viewModel: AscentsVM

    // Optional: consistent ordering
    private let gradeOrder: [String] = ["V0", "V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SendsByGradeView(viewModel: viewModel)
                .background(Color.raw.slate100)
        }
        .listRowSeparator(.visible)
        .contentMargins(.horizontal, 16)
        .padding(.top, 8)
        .background(Color.raw.slate100)
    }
}

#Preview {
    ContentView()
}
