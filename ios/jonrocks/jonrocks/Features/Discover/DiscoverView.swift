import SwiftUI

struct DiscoverView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Discover")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Discover content will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DiscoverView()
}

