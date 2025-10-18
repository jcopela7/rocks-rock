import SwiftUI
import Combine

@MainActor
final class AscentsVM: ObservableObject {
    @Published var ascents: [AscentDTO] = []
    @Published var loading = false
    @Published var error: String?

    private let api = APIClient()

    // demo IDs you seeded
    let demoUser = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    let demoLocation = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    func load() async {
        loading = true; defer { loading = false }
        do {
            ascents = try await api.listAscents(userId: demoUser)
            error = nil
        } catch {
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
            self.error = error.localizedDescription
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = AscentsVM()

    var body: some View {
        NavigationStack {
            List(vm.ascents) { a in
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(a.style.capitalized) • Attempts \(a.attempts)")
                        .font(.headline)
                    Text(a.climbedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .overlay {
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
        }
    }
}
