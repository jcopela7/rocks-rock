//
//  AscentsModelView.swift
//  jonrocks
//
//  Created by Jonathan Cope on 2025-11-14.
//
import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class AscentsVM: ObservableObject {
    @Published var ascents: [AscentDTO] = []
    @Published var ascentsByLocation: [CountOfAscentsByLocationDTO] = []
    @Published var ascentsByGrade: [CountOfAscentsByGradeDTO] = []
    @Published var routes: [RouteDTO] = []
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

    func loadAscents() async {
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

    func loadCountOfAscentsGroupByLocation() async {
        loading = true; defer { loading = false }
        do {
            let count = try await api.getCountOfAscentsGroupByLocation(userId: demoUser)
            ascentsByLocation = count
            error = nil
        } catch {
            print("Backend error in loadCountOfAscentsGroupByLocation(): \(error)")
            self.error = error.localizedDescription
        }
    }

    func loadCountOfAscentsByGrade(discipline: String) async {
        loading = true; defer { loading = false }
        do {
            let count = try await api.getCountOfAscentsByGrade(userId: demoUser, discipline: discipline)
            ascentsByGrade = count
            error = nil
        } catch {
            print("Backend error in loadCountOfAscentsByGrade(): \(error)")
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
                ascent.routeName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
}

struct AscentFormData {
    var routeId: UUID? = nil
    var style: String = "attempt"
    var attempts: Int = 1
    var rating: String = ""
    var notes: String = ""
    var climbedAt: Date = .init()

    var createAscentRequest: CreateAscentRequest {
        CreateAscentRequest(
            userId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, // demoUser
            routeId: routeId,
            locationId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, // demoLocation
            style: style,
            attempts: attempts,
            rating: rating.isEmpty ? nil : Int(rating),
            notes: notes.isEmpty ? nil : notes,
            climbedAt: climbedAt
        )
    }
}
