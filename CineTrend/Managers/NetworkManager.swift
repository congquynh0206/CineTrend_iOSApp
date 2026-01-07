//
//  NetwordManager.swift
//  CineTrend
//
//  Created by Trangptt on 28/12/25.
//

import Foundation

// Các lỗi có thể xảy ra
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error) // Lỗi chi tiết
    case unknownError
}

// Các API - endpoint
enum Endpoint {
    case trending(page: Int)
    case nowPlaying(page: Int)
    case upcoming(page: Int)
    case similar(id: Int)
    case movieDetail(id: Int)
    case search(query: String, page: Int)
    case videos(movieId: Int)
    case credits(movieId: Int)
    case personDetail(id: Int)
    case personMovieCredits(id: Int)
    
    // Đường dẫn tương ứng
    var path: String {
        switch self {
        case .trending:             return "/trending/movie/day"
        case .nowPlaying:           return "/movie/now_playing"
        case .upcoming:             return "/movie/upcoming"
        case .similar(let id):      return "/movie/\(id)/similar"
        case .movieDetail(let id):  return "/movie/\(id)"
        case .search:               return "/search/movie"
        case .videos(let id):       return "/movie/\(id)/videos"
        case .credits(let id):      return "/movie/\(id)/credits"
        case .personDetail(let id): return "/person/\(id)"
        case .personMovieCredits(let id): return "/person/\(id)/movie_credits"
        }
    }
    
    // Tạo URL hoàn chỉnh kèm tham số
    var url: URL? {
        var components = URLComponents(string: Constants.baseURL + path)
        var queryItems = [URLQueryItem(name: "api_key", value: Constants.apiKey)]
        
        // Thêm các tham số riêng tuỳ từng loại request
        switch self {
        case .trending(let page), .nowPlaying(let page), .upcoming(let page), .search(_, let page):
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        default: break
        }
        
        // Nếu là search thì thêm query
        if case .search(let query, _) = self {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // Generic
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        // Gọi API
        let (data, response) = try await session.data(from: url)
        
        // Check Status Code
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        // Decode
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            print("Lỗi Decode tại API [\(endpoint.path)]: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}
