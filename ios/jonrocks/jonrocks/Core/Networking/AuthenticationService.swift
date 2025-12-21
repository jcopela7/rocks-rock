import Auth0
import Combine
import Foundation

@MainActor
class AuthenticationService: ObservableObject {
  static var shared: AuthenticationService?

  @Published var isAuthenticated = false
  @Published var user: UserInfo?
  @Published var accessToken: String?
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let clientId = AuthConfig.clientId
  private let domain = AuthConfig.domain
  private let authentication: Authentication
  private let credentialsManager: CredentialsManager
  private var tokenExpirationDate: Date?
  private let tokenRefreshThreshold: TimeInterval = 300  // 5 minutes before expiration

  init() {
    let cId = AuthConfig.clientId
    let dmn = AuthConfig.domain
    let authInstance = Auth0.authentication(clientId: cId, domain: dmn)
    self.authentication = authInstance
    self.credentialsManager = CredentialsManager(authentication: authInstance)
    Self.shared = self
    Task {
      await checkAuthenticationStatus()
    }
  }

  private func checkAuthenticationStatus() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let credentials = try await credentialsManager.credentials()
      isAuthenticated = true
      accessToken = credentials.accessToken
      APIClient.shared.updateToken(credentials.accessToken)
      updateTokenExpiration(from: credentials.accessToken)
      // Get user info using the access token
      await fetchUserInfo(accessToken: credentials.accessToken)
    } catch {
      print("❌ Failed to get credentials: \(error.localizedDescription)")
      isAuthenticated = false
      accessToken = nil
      tokenExpirationDate = nil
      APIClient.shared.updateToken(nil)
    }
  }

  /// Extracts expiration date from JWT token
  private func updateTokenExpiration(from token: String) {
    // JWT tokens have 3 parts separated by dots: header.payload.signature
    let parts = token.split(separator: ".")
    guard parts.count == 3 else { return }

    // Decode the payload (second part)
    let payload = String(parts[1])
    // Add padding if needed for base64 decoding
    var base64 =
      payload
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let remainder = base64.count % 4
    if remainder > 0 {
      base64 = base64.padding(toLength: base64.count + 4 - remainder, withPad: "=", startingAt: 0)
    }

    guard let data = Data(base64Encoded: base64),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let exp = json["exp"] as? TimeInterval
    else {
      return
    }

    tokenExpirationDate = Date(timeIntervalSince1970: exp)
  }

  /// Refreshes the token if needed (expired or close to expiring)
  /// Returns the new access token, or nil if refresh failed
  func refreshTokenIfNeeded() async -> String? {
    // Check if token is expired or close to expiring
    if let expiration = tokenExpirationDate,
      expiration.timeIntervalSinceNow > tokenRefreshThreshold
    {
      // Token is still valid and not close to expiring
      return accessToken
    }

    // Token needs refresh - use CredentialsManager to get fresh credentials
    do {
      let credentials = try await credentialsManager.credentials()
      let newToken = credentials.accessToken
      accessToken = newToken
      APIClient.shared.updateToken(newToken)
      updateTokenExpiration(from: newToken)
      print("✅ Token refreshed successfully")
      return newToken
    } catch {
      print("❌ Token refresh failed: \(error.localizedDescription)")
      // If refresh fails, user needs to log in again
      await handleRefreshFailure()
      return nil
    }
  }

  /// Handles refresh failure by logging out the user
  private func handleRefreshFailure() async {
    isAuthenticated = false
    accessToken = nil
    tokenExpirationDate = nil
    user = nil
    APIClient.shared.updateToken(nil)
    _ = credentialsManager.clear()
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
      updateTokenExpiration(from: credentials.accessToken)
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
      tokenExpirationDate = nil
      APIClient.shared.updateToken(nil)
    } catch {
      errorMessage = "Logout failed: \(error.localizedDescription)"
    }
  }
}
