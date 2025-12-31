//
//  NetwordManager.swift
//  CineTrend
//
//  Created by Trangptt on 28/12/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    // Hàm lấy phim Trending
    func getTrendingMovies() async throws -> [Movie] {
        let endpoint = "\(Constants.baseURL)/trending/movie/day?api_key=\(Constants.apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Dịch JSON sang Swift
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(MovieResponse.self, from: data)
            return result.results
        } catch {
            print("Lỗi dịch dữ liệu: \(error)")
            throw NetworkError.invalidData
        }
    }
    
    
    // Ham lay phim dang chieu
    func getNowPlayingMovies () async throws -> [Movie]{
        let endpoint = "\(Constants.baseURL)/movie/now_playing?api_key=\(Constants.apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
            throw NetworkError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(MovieResponse.self, from: data)
            return result.results
        }catch {
            throw NetworkError.invalidData
        }
    }
    
    
    // Hàm lấy phim Sắp chiếu 
        func getUpcomingMovies() async throws -> [Movie] {
            let endpoint = "\(Constants.baseURL)/movie/upcoming?api_key=\(Constants.apiKey)"
            guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
            let result = try JSONDecoder().decode(MovieResponse.self, from: data)
            return result.results
        }
    
    
    
    // Hàm lấy danh sách trailer của phim
    func getMovieVideos(movieId: Int) async throws -> [Video] {
        // Endpoint
        let endpoint = "\(Constants.baseURL)/movie/\(movieId)/videos?api_key=\(Constants.apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(VideoResponse.self, from: data)
            return result.results
        } catch {
            print("Lỗi decode video: \(error)")
            throw NetworkError.invalidData
        }
        
    }
    
    // Lấy danh sách diễn viên
    func getMovieCredits(movieId: Int) async throws -> [Cast] {
        let endpoint = "\(Constants.baseURL)/movie/\(movieId)/credits?api_key=\(Constants.apiKey)"
        
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(CreditsResponse.self, from: data)
            return result.cast
        } catch {
            print("Lỗi decode cast: \(error)")
            throw NetworkError.invalidData
        }
    }
    
    
    
}
