//
//  APIClientHelpers.swift
//  jonrocks
//
//  Created by Jonathan Cope on 2025-10-21.
//

import Foundation

final class APIClientHelpers {
  private let base: URL
  private let session: URLSession
  private let enc: JSONEncoder
  private let dec: JSONDecoder
  private var refreshTask: Task<String?, Never>?

  init(base: URL = AppConfig.apiBaseURL, session: URLSession = .shared) {
    self.base = base
    self.session = session

    enc = JSONEncoder()
    enc.dateEncodingStrategy = .iso8601

    dec = JSONDecoder()
    dec.dateDecodingStrategy = .iso8601
  }

  private func addAuthHeader(to request: inout URLRequest, token: String) {
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    print("🔑 Adding Authorization header with token (length: \(token.count))")
  }

  func get<T: Decodable>(
    _ path: String,
    query: [URLQueryItem] = [],
    token: String,
    refreshToken: (() async -> String?)? = nil
  ) async throws -> T {
    return try await performRequest(
      path: path,
      query: query,
      method: "GET",
      body: nil as String?,
      token: token,
      refreshToken: refreshToken
    ) { token in
      try await self.getWithoutRefresh(path, query: query, token: token)
    }
  }

  private func getWithoutRefresh<T: Decodable>(
    _ path: String,
    query: [URLQueryItem] = [],
    token: String
  ) async throws -> T {
    var comps = URLComponents(
      url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
    if !query.isEmpty { comps.queryItems = query }
    guard let url = comps.url else { throw APIError.invalidURL }

    print("🌐 GET \(url.path)")
    var req = URLRequest(url: url)
    addAuthHeader(to: &req, token: token)

    let (data, resp) = try await session.data(for: req)
    let http = resp as? HTTPURLResponse
    print("📥 Response: \(http?.statusCode ?? -1) for \(url.path)")

    guard let http = http, (200..<300).contains(http.statusCode) else {
      let body = String(data: data, encoding: .utf8)
      print("❌ HTTP Error \(http?.statusCode ?? -1): \(body ?? "no body")")
      throw APIError.badStatus(http?.statusCode ?? -1, body)
    }

    if let responseBody = String(data: data, encoding: .utf8) {
      print("📦 Response body (first 200 chars): \(String(responseBody.prefix(200)))")
    }

    do {
      let decoded = try dec.decode(T.self, from: data)
      print("✅ Successfully decoded response for \(url.path)")
      return decoded
    } catch {
      print("❌ Decode error for \(url.path): \(error)")
      if let jsonString = String(data: data, encoding: .utf8) {
        print("❌ JSON that failed to decode: \(jsonString)")
      }
      throw APIError.decode(error)
    }
  }

  func post<Body: Encodable, T: Decodable>(
    _ path: String,
    body: Body,
    token: String,
    refreshToken: (() async -> String?)? = nil
  ) async throws -> T {
    return try await performRequest(
      path: path,
      query: [],
      method: "POST",
      body: body,
      token: token,
      refreshToken: refreshToken
    ) { token in
      try await self.postWithoutRefresh(path, body: body, token: token)
    }
  }

  private func postWithoutRefresh<Body: Encodable, T: Decodable>(
    _ path: String,
    body: Body,
    token: String
  ) async throws -> T {
    let url = base.appendingPathComponent(path)
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try enc.encode(body)
    addAuthHeader(to: &req, token: token)

    let (data, resp) = try await session.data(for: req)
    guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let body = String(data: data, encoding: .utf8)
      throw APIError.badStatus((resp as? HTTPURLResponse)?.statusCode ?? -1, body)
    }
    do { return try dec.decode(T.self, from: data) } catch { throw APIError.decode(error) }
  }

  func put<Body: Encodable, T: Decodable>(
    _ path: String,
    body: Body,
    token: String,
    refreshToken: (() async -> String?)? = nil
  ) async throws -> T {
    return try await performRequest(
      path: path,
      query: [],
      method: "PUT",
      body: body,
      token: token,
      refreshToken: refreshToken
    ) { token in
      try await self.putWithoutRefresh(path, body: body, token: token)
    }
  }

  private func putWithoutRefresh<Body: Encodable, T: Decodable>(
    _ path: String,
    body: Body,
    token: String
  ) async throws -> T {
    let url = base.appendingPathComponent(path)
    var req = URLRequest(url: url)
    req.httpMethod = "PUT"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.httpBody = try enc.encode(body)
    addAuthHeader(to: &req, token: token)
  
    let (data, resp) = try await session.data(for: req)
    guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let body = String(data: data, encoding: .utf8)
      throw APIError.badStatus((resp as? HTTPURLResponse)?.statusCode ?? -1, body)
    }
    do { return try dec.decode(T.self, from: data) } catch { throw APIError.decode(error) }
  }

  func delete<T: Decodable>(
    _ path: String,
    body: Encodable? = nil,
    token: String,
    refreshToken: (() async -> String?)? = nil
  ) async throws -> T {
    return try await performRequest(
      path: path,
      query: [],
      method: "DELETE",
      body: body,
      token: token,
      refreshToken: refreshToken
    ) { token in
      try await self.deleteWithoutRefresh(path, body: body, token: token)
    }
  }

  private func deleteWithoutRefresh<T: Decodable>(
    _ path: String,
    body: Encodable? = nil,
    token: String
  ) async throws -> T {
    let url = base.appendingPathComponent(path)
    var req = URLRequest(url: url)
    req.httpMethod = "DELETE"
    addAuthHeader(to: &req, token: token)

    if let body = body {
      req.httpBody = try enc.encode(body)
    }

    let (data, resp) = try await session.data(for: req)
    guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      let body = String(data: data, encoding: .utf8)
      throw APIError.badStatus((resp as? HTTPURLResponse)?.statusCode ?? -1, body)
    }

    // Handle 204 No Content response
    if http.statusCode == 204 || data.isEmpty {
      // Return empty response for 204 or empty data
      return try dec.decode(T.self, from: "{}".data(using: .utf8)!)
    }

    do { return try dec.decode(T.self, from: data) } catch { throw APIError.decode(error) }
  }

  /// Generic request handler that supports token refresh on 401 errors
  private func performRequest<T>(
    path: String,
    query: [URLQueryItem],
    method: String,
    body: (any Encodable)?,
    token: String,
    refreshToken: (() async -> String?)?,
    makeRequest: @escaping (String) async throws -> T
  ) async throws -> T {
    // First attempt
    do {
      return try await makeRequest(token)
    } catch APIError.badStatus(let statusCode, _) where statusCode == 401 {
      // Token expired - try to refresh
      guard let refreshToken = refreshToken else {
        throw APIError.badStatus(401, "Unauthorized - token expired and no refresh available")
      }

      // Ensure only one refresh happens at a time
      let newToken: String?
      if let existingTask = refreshTask {
        // Another request is already refreshing, wait for it
        newToken = await existingTask.value
      } else {
        // Start a new refresh task
        let task = Task<String?, Never> {
          await refreshToken()
        }
        refreshTask = task
        newToken = await task.value
        refreshTask = nil
      }

      guard let newToken = newToken else {
        throw APIError.badStatus(401, "Unauthorized - token refresh failed")
      }

      // Retry with new token
      return try await makeRequest(newToken)
    }
  }
}
