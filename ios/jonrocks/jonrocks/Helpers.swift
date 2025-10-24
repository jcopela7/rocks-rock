//
//  Helpers.swift
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
    
    init(base: URL = AppConfig.apiBaseURL, session: URLSession = .shared) {
        self.base = base
        self.session = session
        
        enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        
        dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
    }
    
    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = []) async throws -> T {
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
    
    func post<Body: Encodable, T: Decodable>(_ path: String, body: Body) async throws -> T {
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
    
    func delete<T: Decodable>(_ path: String, body: Encodable? = nil) async throws -> T {
        let url = base.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        
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
        
        do { return try dec.decode(T.self, from: data) }
        catch { throw APIError.decode(error) }
    }
}
