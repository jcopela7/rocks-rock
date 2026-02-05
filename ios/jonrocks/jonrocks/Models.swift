import Foundation

struct APIListEnvelope<T: Decodable>: Decodable {
  let data: T
}

struct UserDTO: Codable, Identifiable {
  let id: UUID
  let displayName: String
  let email: String?
  let firstName: String?
  let createdAt: Date?
}

struct UpdateUserRequest: Encodable {
  let displayName: String
  let firstName: String?
}

struct LocationDTO: Codable, Identifiable {
  let id: UUID
  let name: String
  let type: String  // "gym" | "crag"
  let description: String?
  let latitude: Double?
  let longitude: Double?
}

struct RouteDTO: Codable, Identifiable {
  let id: UUID
  let locationId: UUID
  let name: String?
  let discipline: String  // "boulder" | "sport" | "trad"
  let description: String?
  let gradeSystem: String  // "V" | "YDS" | "Font"
  let gradeValue: String
  let gradeRank: Int
  let starRating: Int?  // 1-5 stars
  let createdAt: Date?
  let updatedAt: Date?
}

struct AscentDTO: Codable, Identifiable {
  let id: UUID
  let userId: UUID
  let routeId: UUID?
  let routeName: String?
  let routeDiscipline: String?  // "boulder" | "sport" | "trad" | "board"
  let locationId: UUID?
  let locationName: String?
  let routeGradeValue: String?
  let routeGradeRank: Int?
  let style: String
  let attempts: Int
  let rating: Int?
  let notes: String?
  let climbedAt: Date
}

struct CountOfAscentsByLocationDTO: Codable {
  let locationName: String
  let totalAscents: Int
}

struct CountOfAscentsByGradeDTO: Codable {
  let routeDiscipline: String
  let gradeSystem: String
  let gradeValue: String
  let gradeRank: Int
  let totalAscents: Int
}

struct MaxGradeByDisciplineDTO: Codable {
  let maxGrade: Int
}

struct CountOfAscentsByDisciplineDTO: Codable {
  let totalAscents: Int
}

struct CreateAscentRequest: Encodable {
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
