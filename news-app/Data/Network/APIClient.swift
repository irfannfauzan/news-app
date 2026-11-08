//
//  APIClient.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

// MARK: - Protocol

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// MARK: - Client

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let headers: [String: String]

    init(
        session: URLSession = NetworkSession.api,
        decoder: JSONDecoder = APIClient.defaultDecoder,
        headers: [String: String] = ["X-Api-Key": SecretKey.apiKey]
    ) {
        self.session = session
        self.decoder = decoder
        self.headers = headers
    }

    static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url() else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        #if DEBUG
        print("[\(request.httpMethod ?? "")] \(url.absoluteString)")
        #endif

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIError.transportError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = (try? decoder.decode(NewsAPIErrorDTO.self, from: data))?.message  
            throw APIError.httpStatus(httpResponse.statusCode, message: message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
