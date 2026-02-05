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
  @Published var maxGradeByDiscipline: MaxGradeByDisciplineDTO? = nil
  @Published var totalCountOfAscentsByDiscipline: CountOfAscentsByDisciplineDTO? = nil
  @Published var ascentsByLocation: [CountOfAscentsByLocationDTO] = []
  @Published var ascentsByGrade: [CountOfAscentsByGradeDTO] = []
  @Published var routes: [RouteDTO] = []
  @Published var loading: Bool = false
  @Published var error: String? = nil
  @Published var imagesByAscent: [UUID: [LocalImageRef]] = [:]
  @Published var searchText: String = ""

  var api: APIClient
  private let imagesKey = "imagesByAscent.v1"
  private let authService: AuthenticationService

  init(authService: AuthenticationService) {
    self.authService = authService
    self.api = APIClient.shared
    loadImageRefs()
  }

  // MARK: API

  private func isCancellation(_ error: Error) -> Bool {
    if error is CancellationError { return true }
    if let urlError = error as? URLError, urlError.code == .cancelled { return true }
    return false
  }

  func loadAscents() async {
    loading = true
    defer { loading = false }
    do {
      ascents = try await api.listAscents()
      error = nil
    } catch {
      if isCancellation(error) { return }
      print("Backend error in load(): \(error)")
      self.error = error.localizedDescription
    }
  }

  func addAttempt() async {
    do {
      let req = CreateAscentRequest(
        routeId: nil,
        locationId: nil,  // You may want to set this based on user selection
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
    loading = true
    defer { loading = false }
    do {
      let count = try await api.getCountOfAscentsGroupByLocation()
      ascentsByLocation = count
      error = nil
    } catch {
      if isCancellation(error) { return }
      print("Backend error in loadCountOfAscentsGroupByLocation(): \(error)")
      self.error = error.localizedDescription
    }
  }

  func loadCountOfAscentsByGrade(discipline: String) async {
    loading = true
    defer { loading = false }
    do {
      let count = try await api.getCountOfAscentsByGrade(discipline: discipline)
      ascentsByGrade = count
      error = nil
    } catch {
      if isCancellation(error) { return }
      print("Backend error in loadCountOfAscentsByGrade(): \(error)")
      self.error = error.localizedDescription
    }
  }

  func loadMaxGradeByDiscipline(discipline: String) async {
    loading = true
    defer { loading = false }
    do {
      let maxGrade = try await api.getMaxGradeByDiscipline(discipline: discipline)
      maxGradeByDiscipline = maxGrade
      error = nil
    } catch {
      if isCancellation(error) { return }
      print("Backend error in loadMaxGradeByDiscipline(): \(error)")
      self.error = error.localizedDescription
    }
  }

  func loadTotalCountOfAscentsByDiscipline(discipline: String) async {
    loading = true
    defer { loading = false }
    do {
      let count = try await api.getTotalCountOfAscentsByDiscipline(discipline: discipline)
      totalCountOfAscentsByDiscipline = count
      error = nil
    } catch {
      if isCancellation(error) { return }
      print("Backend error in loadTotalCountOfAscentsByDiscipline(): \(error)")
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
  var locationId: UUID? = nil
  var style: String = "attempt"
  var attempts: Int = 1
  var rating: String = ""
  var notes: String = ""
  var climbedAt: Date = .init()

  var createAscentRequest: CreateAscentRequest {
    CreateAscentRequest(
      routeId: routeId,
      locationId: locationId,
      style: style,
      attempts: attempts,
      rating: rating.isEmpty ? nil : Int(rating),
      notes: notes.isEmpty ? nil : notes,
      climbedAt: climbedAt
    )
  }
}
