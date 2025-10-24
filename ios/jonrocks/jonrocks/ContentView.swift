import SwiftUI
import Combine
import PhotosUI
import Foundation
import UIKit

// MARK: - ViewModel

@MainActor
final class AscentsVM: ObservableObject {
    @Published var ascents: [AscentDTO] = []
    @Published var loading: Bool = false
    @Published var error: String? = nil
    @Published var imagesByAscent: [UUID: [LocalImageRef]] = [:]

    private let api = APIClient()
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
           let map = try? JSONDecoder().decode([UUID: [LocalImageRef]].self, from: data) {
            self.imagesByAscent = map
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
}

// MARK: - View

struct ContentView: View {
    @StateObject private var vm = AscentsVM()

    @State private var ascentToDelete: AscentDTO?
    @State private var showingDeleteAlert = false

    @State private var pickingForAscent: AscentDTO?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            List(vm.ascents) { a in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(a.style.capitalized) • Attempts \(a.attempts)")
                            .font(.headline)
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "camera.fill")
                                .imageScale(.medium)
                                .padding(6)
                        }
                        // Remember which ascent we’re attaching to
                        .onTapGesture { pickingForAscent = a }
                    }

                    if let ref = vm.imagesByAscent[a.id]?.first,
                       let ui = LocalImageStore.load(ref) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .clipped()
                    }

                    Text(a.id.uuidString)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(a.climbedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", role: .destructive) {
                        ascentToDelete = a
                        showingDeleteAlert = true
                    }
                }
            }
            .overlay(alignment: .center) {
                if vm.loading { ProgressView() }
                if let e = vm.error {
                    Text(e).foregroundStyle(.red).padding()
                }
            }
            .navigationTitle("Ascents")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reload") { Task { await vm.load() } }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add") { Task { await vm.addAttempt() } }
                }
            }
            .task { await vm.load() }
            .alert("Delete Ascent", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { ascentToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let ascent = ascentToDelete {
                        Task { await vm.deleteAscent(ascent) }
                    }
                    ascentToDelete = nil
                }
            } message: {
                if let ascent = ascentToDelete {
                    Text("Are you sure you want to delete this \(ascent.style) ascent? This action cannot be undone.")
                }
            }
            // Handle the picked photo once PhotosPicker selection changes
            .onChange(of: selectedItem) { _, newItem in
                Task { await handlePickedItem(newItem) }
            }
        }
    }

    private func handlePickedItem(_ item: PhotosPickerItem?) async {
        guard let item, let ascent = pickingForAscent else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                vm.addLocalImage(image, to: ascent.id)
            }
        } catch {
            vm.error = "Import failed: \(error.localizedDescription)"
        }
        pickingForAscent = nil
        selectedItem = nil
    }
}

#Preview {
    ContentView()
}
