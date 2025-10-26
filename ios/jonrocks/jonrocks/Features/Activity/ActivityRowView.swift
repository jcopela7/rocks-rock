import SwiftUI
import PhotosUI

struct ActivityRowView: View {
    let ascent: AscentDTO
    @ObservedObject var viewModel: AscentsVM
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var pickingForAscent: AscentDTO?
    @Binding var ascentToDelete: AscentDTO?
    @Binding var showingDeleteAlert: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ascentHeader
            ascentImage
            ascentDetails
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive) {
                ascentToDelete = ascent
                showingDeleteAlert = true
            }
        }
    }

    private var ascentHeader: some View {
        HStack {
            Text("\(ascent.style.capitalized) • Attempts \(ascent.attempts)")
                .font(.headline)
            Spacer()
        }
    }

    @ViewBuilder
    private var ascentImage: some View {
        if let ref = viewModel.imagesByAscent[ascent.id]?.first,
           let ui = LocalImageStore.load(ref) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
        }
    }

    private var ascentDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ascent.notes ?? "")
                .font(.body)
                .foregroundStyle(.secondary)

            Text(ascent.climbedAt.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}

