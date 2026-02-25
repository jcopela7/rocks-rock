import Foundation

enum ClimbFilter {
  case boulder
  case trad
  case sport
  case board
}

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

struct LocationDTO: Codable, Identifiable, Hashable {
  let id: UUID
  let name: String
  let type: String  // "gym" | "crag"
  let description: String?
  let latitude: Double?
  let longitude: Double?

  func hash(into hasher: inout Hasher) { hasher.combine(id) }
  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

struct UserLocationDTO: Codable, Identifiable, Hashable {
  let id: UUID
  let locationId: UUID
  let name: String
  let type: String  // "gym" | "crag"
  let description: String?
  let latitude: Double?
  let longitude: Double?

  func hash(into hasher: inout Hasher) { hasher.combine(id) }
  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

struct CreateUserLocationResponseDTO: Decodable {
  let id: UUID
  let locationId: UUID
  let userId: UUID
}

struct DeleteUserLocationResponseDTO: Decodable {
  let id: UUID
  let locationId: UUID
  let userId: UUID
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
  let locationLatitude: Double?
  let locationLongitude: Double?
  let routeGradeValue: String?
  let routeGradeRank: Int?
  let style: String
  let attempts: Int
  let rating: Int?
  let notes: String?
  let climbedAt: Date
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
