import Foundation

struct APIListEnvelope<T: Decodable>: Decodable {
    let data: T
}

struct UserDTO: Codable, Identifiable {
    let id: UUID
    let displayName: String
    let createdAt: Date?
}

struct LocationDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: String      // "gym" | "crag"
    let latitude: Double?
    let longitude: Double?
}

struct AscentDTO: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let routeId: UUID?
    let locationId: UUID?
    let style: String
    let attempts: Int
    let isOutdoor: Bool
    let rating: Int?
    let notes: String?
    let climbedAt: Date
}

struct CreateAscentRequest: Encodable {
    let userId: UUID
    let routeId: UUID?
    let locationId: UUID?
    let style: String
    let attempts: Int
    let isOutdoor: Bool
    let rating: Int?
    let notes: String?
    let climbedAt: Date
}

struct DeleteAscentRequest:Encodable {
    let id: UUID
}

