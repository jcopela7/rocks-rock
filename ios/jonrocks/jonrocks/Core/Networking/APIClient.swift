import Foundation

enum APIError: Error, LocalizedError {
  case badStatus(Int, String?)
  case invalidURL
  case decode(Error)
  case missingAccessToken
  case other(Error)

  var errorDescription: String? {
    switch self {
    case .badStatus(let code, let msg): return "HTTP \(code): \(msg ?? "")"
    case .invalidURL: return "Invalid URL"
    case .decode(let err): return "Decode error: \(err)"
    case .missingAccessToken: return "Authentication required. Missing access token."
    case .other(let err): return err.localizedDescription
    }
  }
}

final class APIClient {
  static let shared = APIClient()

  private let helpers: APIClientHelpers
  private var accessToken: String?

  // Designated initializer
  init(helpers: APIClientHelpers = APIClientHelpers(), accessToken: String? = nil) {
    self.helpers = helpers
    self.accessToken = accessToken
  }

  // Convenience initializer to pass base/session/accessToken without managing extra stored properties
  convenience init(
    base: URL = AppConfig.apiBaseURL, session: URLSession = .shared, accessToken: String? = nil
  ) {
    self.init(helpers: APIClientHelpers(base: base, session: session), accessToken: accessToken)
  }

  func updateToken(_ token: String?) {
    accessToken = token
  }

  private func requireToken() throws -> String {
    guard let token = accessToken else {
      throw APIError.missingAccessToken
    }
    return token
  }

  private func getRefreshTokenCallback() -> (() async -> String?)? {
    return { @MainActor in
      guard let authService = AuthenticationService.shared else {
        return nil
      }
      return await authService.refreshTokenIfNeeded()
    }
  }

  // MARK: - Endpoints

  func listAscents(limit: Int = 20) async throws -> [AscentDTO] {
    let env: APIListEnvelope<[AscentDTO]> = try await helpers.get(
      "ascent",  // <- plural
      query: [
        .init(name: "limit", value: String(limit))
      ],
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func createAscent(_ req: CreateAscentRequest) async throws -> AscentDTO {
    // backend alias: POST /api/v1/ascent
    return try await helpers.post(
      "ascent",
      body: req,
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
  }

  func deleteAscent(_ id: UUID) async throws -> AscentDTO {
    let env: APIListEnvelope<AscentDTO> = try await helpers.delete(
      "ascent/\(id.uuidString)",
      body: nil,
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func listLocations(name: String? = nil) async throws -> [LocationDTO] {
    var query: [URLQueryItem] = []
    if let name = name, !name.isEmpty {
      query.append(.init(name: "name", value: name))
    }
    let env: APIListEnvelope<[LocationDTO]> = try await helpers.get(
      "location",
      query: query,
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func listMyLocations(name: String? = nil) async throws -> [UserLocationDTO] {
    var query: [URLQueryItem] = []
    if let name = name, !name.isEmpty {
      query.append(.init(name: "name", value: name))
    }
    let env: APIListEnvelope<[UserLocationDTO]> = try await helpers.get(
      "user/location",
      query: query,
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func createUserLocation(_ locationId: UUID) async throws -> CreateUserLocationResponseDTO {
    let env: APIListEnvelope<CreateUserLocationResponseDTO> = try await helpers.postWithNoBody(
      "user/location/\(locationId.uuidString)",
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func getCountOfAscentsGroupByLocation(discipline: String) async throws
    -> [CountOfAscentsByLocationDTO]
  {
    let env: APIListEnvelope<[CountOfAscentsByLocationDTO]> = try await helpers.get(
      "ascent/count/location",
      query: [
        .init(name: "discipline", value: discipline)
      ],
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func getCountOfAscentsByGrade(discipline: String) async throws -> [CountOfAscentsByGradeDTO] {
    let env: APIListEnvelope<[CountOfAscentsByGradeDTO]> = try await helpers.get(
      "ascent/count/grade",
      query: [
        .init(name: "discipline", value: discipline)
      ],
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func getMaxGradeByDiscipline(discipline: String) async throws -> MaxGradeByDisciplineDTO {
    let env: APIListEnvelope<MaxGradeByDisciplineDTO> = try await helpers.get(
      "ascent/max/grade",
      query: [
        .init(name: "discipline", value: discipline)
      ],
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func getTotalCountOfAscentsByDiscipline(discipline: String) async throws
    -> CountOfAscentsByDisciplineDTO
  {
    let env: APIListEnvelope<CountOfAscentsByDisciplineDTO> = try await helpers.get(
      "ascent/count/discipline",
      query: [
        .init(name: "discipline", value: discipline)
      ],
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func listRoutes() async throws -> [RouteDTO] {
    let env: APIListEnvelope<[RouteDTO]> = try await helpers.get(
      "route",
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func getUser() async throws -> UserDTO {
    let env: APIListEnvelope<UserDTO> = try await helpers.get(
      "user/me",
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }

  func updateUser(_ req: UpdateUserRequest) async throws -> UserDTO {
    let env: APIListEnvelope<UserDTO> = try await helpers.put(
      "user/me",
      body: req,
      token: try requireToken(),
      refreshToken: getRefreshTokenCallback()
    )
    return env.data
  }
}
