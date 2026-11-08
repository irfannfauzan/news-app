//
//  APIError.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case transportError(URLError)
    case invalidResponse
    case httpStatus(Int, message: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL Tidak Valid!"
        case .transportError(let error):
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return "Tidak ada koneksi internet!"
            case .cannotFindHost, .dnsLookupFailed:
                return "Server tidak ditemukan!"
            case .cannotConnectToHost:
                return "Tidak dapat terhubung ke server!"
            case .timedOut:
                return "Koneksi timeout, coba lagi."
            case .badURL, .unsupportedURL:
                return "URL tidak valid!"
            case .cancelled:
                return "Request dibatalkan."
            default:
                return "Terjadi kesalahan jaringan: \(error.localizedDescription)"
            }
        case .invalidResponse:
            return "Response tidak valid!"
        case .httpStatus(let code, let message):                  
            return message ?? "Server mengembalikan status \(code)"
        case .decoding(let error):
            return "Gagal decode data: \(error.localizedDescription)"
        }
    }
}
