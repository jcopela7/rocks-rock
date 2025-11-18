import SwiftUI

struct AddView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Add")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Add content will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AddView()
}

