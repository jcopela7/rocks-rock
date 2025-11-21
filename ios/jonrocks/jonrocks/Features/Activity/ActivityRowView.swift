import PhotosUI
import SwiftUI

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
            HStack(alignment: .center, spacing: 4) {
                ascentLocation
                ascentMetadata
            }
            ascentImage
            Spacer()
            ascentDetails
            Spacer()
            HStack(alignment: .center, spacing: 32) {
                ascentMetric(label: "Grade", value: "V5" ?? "")
                ascentMetric(label: "Attempts", value: String(ascent.attempts))
                ascentMetric(label: "Stars", value: String(Int(ascent.rating ?? 0)))
            }
            Spacer()
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
            Text("\(ascent.routeName ?? "")")
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            Spacer()
        }
    }

    private var ascentLocation: some View {
        HStack(spacing: 4) {
            Image("crashpadIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.secondary)
            Text("\(ascent.locationName ?? "")")
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
        }
    }

        private var ascentMetadata: some View {
            Text("• \(ascent.climbedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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

    @ViewBuilder
    private var ascentImage: some View {
        if let ref = viewModel.imagesByAscent[ascent.id]?.first,
           let ui = LocalImageStore.load(ref)
        {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
        }
    }

    private var ascentDetails: some View {
            Text(ascent.notes ?? "")
                .font(.body)
                .foregroundStyle(.secondary)
        }
}

#Preview {
    ContentView()
}
