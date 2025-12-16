import Foundation

enum APIError: Error, LocalizedError {
    case badStatus(Int, String?)
    case invalidURL
    case decode(Error)
    case other(Error)

    var errorDescription: String? {
        switch self {
        case let .badStatus(code, msg): return "HTTP \(code): \(msg ?? "")"
        case .invalidURL: return "Invalid URL"
        case let .decode(err): return "Decode error: \(err)"
        case let .other(err): return err.localizedDescription
        }
    }
}

final class APIClient {
    private let helpers: APIClientHelpers

    // Designated initializer
    init(helpers: APIClientHelpers = APIClientHelpers()) {
        self.helpers = helpers
    }

    // Convenience initializer to pass base/session/accessToken without managing extra stored properties
    convenience init(base: URL = AppConfig.apiBaseURL, session: URLSession = .shared, accessToken: String? = nil) {
        self.init(helpers: APIClientHelpers(base: base, session: session, accessToken: accessToken))
    }

    // MARK: - Endpoints

    func listAscents(limit: Int = 20) async throws -> [AscentDTO] {
        let env: APIListEnvelope<[AscentDTO]> = try await helpers.get(
            "ascent", // <- plural
            query: [
                .init(name: "limit", value: String(limit)),
            ]
        )
        return env.data
    }

    func createAscent(_ req: CreateAscentRequest) async throws -> AscentDTO {
        // backend alias: POST /api/v1/ascent
        return try await helpers.post("ascent", body: req)
    }

    func deleteAscent(_ id: UUID) async throws -> AscentDTO {
        let env: APIListEnvelope<AscentDTO> = try await helpers.delete("ascent/\(id.uuidString)")
        return env.data
    }

    func listLocations() async throws -> [LocationDTO] {
        let env: APIListEnvelope<[LocationDTO]> = try await helpers.get("location")
        return env.data
    }

    func getCountOfAscentsGroupByLocation() async throws -> [CountOfAscentsByLocationDTO] {
        let env: APIListEnvelope<[CountOfAscentsByLocationDTO]> = try await helpers.get("ascent/count/location")
        return env.data
    }

    func getCountOfAscentsByGrade(discipline: String) async throws -> [CountOfAscentsByGradeDTO] {
        let env: APIListEnvelope<[CountOfAscentsByGradeDTO]> = try await helpers.get("ascent/count/grade", query: [
            .init(name: "discipline", value: discipline),
        ])
        return env.data
    }

    func listUsers() async throws -> [UserDTO] {
        let env: APIListEnvelope<[UserDTO]> = try await helpers.get("users")
        return env.data
    }

    func listRoutes() async throws -> [RouteDTO] {
        let env: APIListEnvelope<[RouteDTO]> = try await helpers.get("route")
        return env.data
    }
}
