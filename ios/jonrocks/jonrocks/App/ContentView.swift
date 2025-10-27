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
                    .background(Color.theme.accent)
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
                ActivityRowView(
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

    private var searchBar: some View {
        SearchBar(text: $vm.searchText)
            .padding(.horizontal)
            .padding(.top, 8)
    }

    private var ascentsList: some View {
        List(vm.filteredAscents) { ascent in
            ActivityRowView(
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
    @State private var selected = "Activity"
    @StateObject private var vm = AscentsVM()
    @State private var showingAddForm = false

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.accent)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().layer.cornerRadius = 2
        UISegmentedControl.appearance().clipsToBounds = true
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "You") {
                    showingAddForm = true
                }
                SegmentedPicker(
                    selection: $selected,
                    segments: ["Progress", "Activity"]
                )
                .padding(.horizontal, 16)
                Group {
                    if selected == "Progress" {
                        ProgressView()
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    } else {
                        ActivityLoggingView(vm: vm)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .sheet(isPresented: $showingAddForm) {
                AddActivityFormView(viewModel: vm)
            }
        }
    }
}

#Preview {
    ContentView()
}
