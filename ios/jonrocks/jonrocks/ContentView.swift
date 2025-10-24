import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class AscentsVM: ObservableObject {
    @Published var ascents: [AscentDTO] = []
    @Published var loading: Bool = false
    @Published var error: String? = nil
    @Published var imagesByAscent: [UUID: [LocalImageRef]] = [:]
    @Published var searchText: String = ""

    let api = APIClient()
    private let imagesKey = "imagesByAscent.v1"

    // demo IDs you seeded
    let demoUser = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    let demoLocation = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    init() {
        loadImageRefs()
    }

    // MARK: API

    func load() async {
        loading = true; defer { loading = false }
        do {
            ascents = try await api.listAscents(userId: demoUser)
            error = nil
        } catch {
            print("Backend error in load(): \(error)")
            self.error = error.localizedDescription
        }
    }

    func addAttempt() async {
        do {
            let req = CreateAscentRequest(
                userId: demoUser,
                routeId: nil,
                locationId: demoLocation,
                style: "attempt",
                attempts: 1,
                isOutdoor: false,
                rating: nil,
                notes: "Logged from iOS",
                climbedAt: Date()
            )
            let created = try await api.createAscent(req)
            ascents.insert(created, at: 0)
            error = nil
        } catch {
            print("Backend error in addAttempt(): \(error)")
            self.error = error.localizedDescription
        }
    }

    func deleteAscent(_ ascent: AscentDTO) async {
        do {
            _ = try await api.deleteAscent(ascent.id)
            ascents.removeAll { $0.id == ascent.id }
            error = nil
        } catch {
            print("Backend error in deleteAscent(): \(error)")
            self.error = error.localizedDescription
        }
    }

    // MARK: Local images

    private func loadImageRefs() {
        if let data = UserDefaults.standard.data(forKey: imagesKey),
           let map = try? JSONDecoder().decode([UUID: [LocalImageRef]].self, from: data)
        {
            imagesByAscent = map
        }
    }

    private func saveImageRefs() {
        if let data = try? JSONEncoder().encode(imagesByAscent) {
            UserDefaults.standard.set(data, forKey: imagesKey)
        }
    }

    func addLocalImage(_ image: UIImage, to ascentId: UUID) {
        do {
            let ref = try LocalImageStore.saveJPEG(image)
            var arr = imagesByAscent[ascentId] ?? []
            arr.insert(ref, at: 0)
            imagesByAscent[ascentId] = arr
            saveImageRefs()
        } catch {
            self.error = "Save image failed: \(error.localizedDescription)"
        }
    }

    // MARK: Search functionality

    var filteredAscents: [AscentDTO] {
        if searchText.isEmpty {
            return ascents
        } else {
            return ascents.filter { ascent in
                ascent.style.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct AscentFormData {
    var style: String = "attempt"
    var attempts: Int = 1
    var isOutdoor: Bool = false
    var rating: String = ""
    var notes: String = ""
    var climbedAt: Date = .init()

    var createAscentRequest: CreateAscentRequest {
        CreateAscentRequest(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, // demoUser
            routeId: nil,
            locationId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, // demoLocation
            style: style,
            attempts: attempts,
            isOutdoor: isOutdoor,
            rating: rating.isEmpty ? nil : Int(rating),
            notes: notes.isEmpty ? nil : notes,
            climbedAt: climbedAt
        )
    }
}

struct AddAscentFormView: View {
    @ObservedObject var viewModel: AscentsVM
    @Environment(\.dismiss) private var dismiss

    @State private var formData = AscentFormData()
    @State private var isSubmitting = false

    private let styleOptions = ["attempt", "send", "flash", "onsight", "redpoint"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Climb Details") {
                    Picker("Style", selection: $formData.style) {
                        ForEach(styleOptions, id: \.self) { style in
                            Text(style.capitalized).tag(style)
                        }
                    }

                    Stepper("Attempts: \(formData.attempts)", value: $formData.attempts, in: 1 ... 20)
                }

                Section("Location") {
                    Toggle("Outdoor Climbing", isOn: $formData.isOutdoor)
                }

                Section("Rating") {
                    TextField("Grade (e.g., 5.10a, V4)", text: $formData.rating)
                        .textInputAutocapitalization(.never)
                }

                Section("Notes") {
                    TextEditor(text: $formData.notes)
                        .frame(minHeight: 80)
                }

                Section("Date") {
                    DatePicker("Climb Date", selection: $formData.climbedAt, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add Ascent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await submitForm()
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
        }
    }

    private func submitForm() async {
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let request = formData.createAscentRequest
            let created = try await viewModel.api.createAscent(request)
            await MainActor.run {
                viewModel.ascents.insert(created, at: 0)
                viewModel.error = nil
                dismiss()
            }
        } catch {
            await MainActor.run {
                viewModel.error = error.localizedDescription
            }
        }
    }
}

struct AscentRowView: View {
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
        VStack(alignment: .leading, spacing: 4) {
            Text(ascent.notes ?? "")
                .font(.body)
                .foregroundStyle(.secondary)
            Text(ascent.climbedAt.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(.secondary)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search by style...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.white))
        .cornerRadius(10)
    }
}

struct AppHeader: View {
    let title: String
    let onAddTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: onAddTap) {
                Label("Add", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemBlue))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

struct ProgressView: View {
    var body: some View {
        VStack {
            Text("Your climbing progress and statistics will appear here.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ActivityLoggingView: View {
    @ObservedObject var vm: AscentsVM

    @State private var ascentToDelete: AscentDTO?
    @State private var showingDeleteAlert = false

    @State private var pickingForAscent: AscentDTO?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            SearchBar(text: $vm.searchText)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            List(vm.filteredAscents) { ascent in
                AscentRowView(
                    ascent: ascent,
                    viewModel: vm,
                    selectedItem: $selectedItem,
                    pickingForAscent: $pickingForAscent,
                    ascentToDelete: $ascentToDelete,
                    showingDeleteAlert: $showingDeleteAlert
                )
                // iOS 17+: trim default side gutters
                .listRowSeparator(.visible)
            }
            .listStyle(.plain)
            .contentMargins(.horizontal, 12) // iOS 17
        }
        .overlay(alignment: .center) {
            loadingOverlay
        }
        .task { await vm.load() }
        .alert("Delete Ascent", isPresented: $showingDeleteAlert) {
            deleteAlertContent
        } message: {
            deleteAlertMessage
        }
    }

    // MARK: - Sub-expressions

    private var searchBar: some View {
        SearchBar(text: $vm.searchText)
            .padding(.horizontal)
            .padding(.top, 8)
    }

    private var ascentsList: some View {
        List(vm.filteredAscents) { ascent in
            AscentRowView(
                ascent: ascent,
                viewModel: vm,
                selectedItem: $selectedItem,
                pickingForAscent: $pickingForAscent,
                ascentToDelete: $ascentToDelete,
                showingDeleteAlert: $showingDeleteAlert
            )
        }
    }

    private var loadingOverlay: some View {
        Group {
            if vm.loading { ProgressView() }
            if let e = vm.error {
                Text(e).foregroundStyle(.red).padding()
            }
        }
    }

    @ViewBuilder
    private var deleteAlertContent: some View {
        Button("Cancel", role: .cancel) { ascentToDelete = nil }
        Button("Delete", role: .destructive) {
            if let ascent = ascentToDelete {
                Task { await vm.deleteAscent(ascent) }
            }
            ascentToDelete = nil
        }
    }

    @ViewBuilder
    private var deleteAlertMessage: some View {
        if let ascent = ascentToDelete {
            Text("Are you sure you want to delete this \(ascent.style) ascent? This action cannot be undone.")
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 1
    @StateObject private var vm = AscentsVM()
    @State private var showingAddForm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "You") {
                    showingAddForm = true
                }
                Picker("Tab Selection", selection: $selectedTab) {
                    Text("Progress").tag(0)
                    Text("Activity").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 16)
                Group {
                    if selectedTab == 0 {
                        ProgressView() // no NavigationStack inside
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    } else {
                        ActivityLoggingView(vm: vm) // no NavigationStack inside
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .sheet(isPresented: $showingAddForm) {
                AddAscentFormView(viewModel: vm)
            }
        }
    }
}

#Preview {
    ContentView()
}
