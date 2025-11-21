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
    let type: String // "gym" | "crag"
    let description: String?
    let latitude: Double?
    let longitude: Double?
}

struct RouteDTO: Codable, Identifiable {
    let id: UUID
    let locationId: UUID
    let name: String?
    let discipline: String // "boulder" | "sport" | "trad"
    let description: String?
    let gradeSystem: String // "V" | "YDS" | "Font"
    let gradeValue: String
    let gradeRank: Int
    let color: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct AscentDTO: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let routeId: UUID?
    let locationId: UUID?
    let style: String
    let attempts: Int
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
    let rating: Int?
    let notes: String?
    let climbedAt: Date
}

struct DeleteAscentRequest: Encodable {
    let id: UUID
}
