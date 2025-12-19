import Combine
import Foundation
import SwiftUI

@MainActor
final class UserVM: ObservableObject {
  @Published var user: UserDTO?
  @Published var isLoading: Bool = false
  @Published var errorMessage: String? = nil

  var api: APIClient
  private let authService: AuthenticationService
  private var cancellables = Set<AnyCancellable>()

  init(authService: AuthenticationService) {
    self.authService = authService
    self.api = APIClient.shared
  }

  func loadUser() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      user = try await api.getUser()
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}