import Auth0
import Combine
import Foundation

@MainActor
class AuthenticationService: ObservableObject {
  @Published var isAuthenticated = false
  @Published var user: UserInfo?
  @Published var accessToken: String?
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let clientId = AuthConfig.clientId
  private let domain = AuthConfig.domain
  private let authentication: Authentication
  private let credentialsManager: CredentialsManager

  init() {
    authentication = Auth0.authentication(clientId: clientId, domain: domain)
    credentialsManager = CredentialsManager(authentication: authentication)
    Task {
      await checkAuthenticationStatus()
    }
  }

  private func checkAuthenticationStatus() async {
    isLoading = true
    defer { isLoading = false }

    guard let credentials = try? await credentialsManager.credentials() else {
      isAuthenticated = false
      accessToken = nil
      APIClient.shared.updateToken(nil)
      return
    }

    isAuthenticated = true
    accessToken = credentials.accessToken
    APIClient.shared.updateToken(credentials.accessToken)
    // Get user info using the access token
    await fetchUserInfo(accessToken: credentials.accessToken)
  }

  private func fetchUserInfo(accessToken: String) async {
    do {
      user = try await authentication.userInfo(withAccessToken: accessToken).start()
    } catch {
      errorMessage = "Failed to fetch user info: \(error.localizedDescription)"
    }
  }

  func login() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      var webAuth =
        Auth0
        .webAuth(clientId: clientId, domain: domain)
        .scope("openid profile email offline_access")

      // Add audience if configured (required for API authentication)
      if let audience = AuthConfig.audience {
        webAuth = webAuth.audience(audience)
      }

      let credentials = try await webAuth.start()

      _ = credentialsManager.store(credentials: credentials)
      isAuthenticated = true
      accessToken = credentials.accessToken
      APIClient.shared.updateToken(credentials.accessToken)
      print("✅ Login successful, access token length: \(credentials.accessToken.count)")
      // Get user info using the access token
      await fetchUserInfo(accessToken: credentials.accessToken)
    } catch {
      errorMessage = "Login failed: \(error.localizedDescription)"
      accessToken = nil
      APIClient.shared.updateToken(nil)
      print("❌ Login error: \(error.localizedDescription)")
    }
  }

  func logout() async {
    isLoading = true
    defer { isLoading = false }

    do {
      try await Auth0.webAuth(clientId: clientId, domain: domain).clearSession()
      _ = credentialsManager.clear()
      isAuthenticated = false
      user = nil
      accessToken = nil
      APIClient.shared.updateToken(nil)
    } catch {
      errorMessage = "Logout failed: \(error.localizedDescription)"
    }
  }
}
