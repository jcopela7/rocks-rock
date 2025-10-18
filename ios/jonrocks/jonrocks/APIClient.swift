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
    private let base: URL
    private let session: URLSession
    private let enc: JSONEncoder
    private let dec: JSONDecoder

    init(base: URL = AppConfig.apiBaseURL, session: URLSession = .shared) {
        self.base = base
        self.session = session

        enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601

        dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
    }

    // MARK: - Generic helpers

    private func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
        var comps = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { comps.queryItems = query }
        guard let url = comps.url else { throw APIError.invalidURL }

        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw APIError.badStatus((resp as? HTTPURLResponse)?.statusCode ?? -1, body)
        }
        do { return try dec.decode(T.self, from: data) }
        catch { throw APIError.decode(error) }
    }

    private func post<Body: Encodable, T: Decodable>(_ path: String, body: Body) async throws -> T {
        let url = base.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try enc.encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw APIError.badStatus((resp as? HTTPURLResponse)?.statusCode ?? -1, body)
        }
        do { return try dec.decode(T.self, from: data) }
        catch { throw APIError.decode(error) }
    }

    // MARK: - Endpoints (adjust paths to your server)

    func listAscents(userId: UUID) async throws -> [AscentDTO] {
        let env: APIListEnvelope<[AscentDTO]> = try await get(
            "ascent",
            query: [
                .init(name: "userId", value: userId.uuidString),
            ]
        )
        return env.data
    }

    func createAscent(_ req: CreateAscentRequest) async throws -> AscentDTO {
        // your server exposes /api/v1/ascent (singular) as an alias
        return try await post("ascent", body: req)
    }

    // Examples for users/locations if you want them now:
    func listLocations() async throws -> [LocationDTO] {
        let env: APIListEnvelope<[LocationDTO]> = try await get("locations")
        return env.data
    }

    func listUsers() async throws -> [UserDTO] {
        let env: APIListEnvelope<[UserDTO]> = try await get("users")
        return env.data
    }
}
