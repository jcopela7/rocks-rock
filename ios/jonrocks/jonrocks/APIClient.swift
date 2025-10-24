import Foundation


enum APIError: Error, LocalizedError {
    case badStatus(Int, String?)
    case invalidURL
    case decode(Error)
    case other(Error)

    var errorDescription: String? {
        switch self {
        case .badStatus(let code, let msg): return "HTTP \(code): \(msg ?? "")"
        case .invalidURL: return "Invalid URL"
        case .decode(let err): return "Decode error: \(err)"
        case .other(let err): return err.localizedDescription
        }
    }
}

final class APIClient {
    private let helpers: APIClientHelpers

    // Designated initializer
    init(helpers: APIClientHelpers = APIClientHelpers()) {
        self.helpers = helpers
    }

    // Convenience initializer to pass base/session without managing extra stored properties
    convenience init(base: URL = AppConfig.apiBaseURL, session: URLSession = .shared) {
        self.init(helpers: APIClientHelpers(base: base, session: session))
    }

    // MARK: - Endpoints

    func listAscents(userId: UUID, limit: Int = 20) async throws -> [AscentDTO] {
        let env: APIListEnvelope<[AscentDTO]> = try await helpers.get(
            "ascent", // <- plural
            query: [
                .init(name: "userId", value: userId.uuidString),
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
        let env: APIListEnvelope<[LocationDTO]> = try await helpers.get("locations")
        return env.data
    }

    func listUsers() async throws -> [UserDTO] {
        let env: APIListEnvelope<[UserDTO]> = try await helpers.get("users")
        return env.data
    }
}
