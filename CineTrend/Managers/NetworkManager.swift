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
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // Hàm lấy phim Trending
    func getTrendingMovies(page : Int = 1) async throws -> [Movie] {
        let endpoint = "\(Constants.baseURL)/trending/movie/day?api_key=\(Constants.apiKey)&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await session.data(from: url)
        
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
    
    //Hàm lấy phim tương tự
    func getSimilarMoives(movieId : Int) async throws -> [Movie]{
        let endpoint = "\(Constants.baseURL)/movie/\(movieId)/similar?api_key=\(Constants.apiKey)"
        
        guard let url = URL(string: endpoint) else{
            throw NetworkError.invalidURL
        }
        let (data,response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else{
            throw NetworkError.invalidResponse
        }
        do{
            let result = try JSONDecoder().decode(MovieResponse.self, from: data)
            return result.results
        }catch{
            print ("Loi lay phim lien quan")
            throw NetworkError.invalidData
        }
    }
    
    
    // Ham lay phim dang chieu
    func getNowPlayingMovies (page : Int = 1) async throws -> [Movie]{
        let endpoint = "\(Constants.baseURL)/movie/now_playing?api_key=\(Constants.apiKey)&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
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
    func getUpcomingMovies(page : Int = 1) async throws -> [Movie] {
        let endpoint = "\(Constants.baseURL)/movie/upcoming?api_key=\(Constants.apiKey)&page=\(page)"
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
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
        
        let (data, response) = try await session.data(from: url)
        
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
        
        let (data, response) = try await session.data(from: url)
        
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
    
    
    
    // Lấy thông tin của 1 dvien
    func getPersonDetail (id: Int) async throws-> Person{
        let endpoint = "\(Constants.baseURL)/person/\(id)?api_key=\(Constants.apiKey)"
        guard let url = URL(string: endpoint) else{
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(Person.self, from: data)
        }catch{
            print("Lỗi lấy tt dvien")
            throw NetworkError.invalidData
        }
    }
    
    // Lấy danh sách phim đã đóng của 1 dvien
    func getPersonMovieCredits(id: Int) async throws -> [Movie] {
        let endpoint = "\(Constants.baseURL)/person/\(id)/movie_credits?api_key=\(Constants.apiKey)"
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let result = try JSONDecoder().decode(PersonMovieCreditsResponse.self, from: data)
        // Lọc bớt phim không có poster
        let movies = result.cast
            .filter { $0.posterPath != nil }
            .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
        return movies
    }
    
    
    // Search
    func searchMovies(query: String, page : Int = 1) async throws -> [Movie] {
        // "Iron Man" -> "Iron%20Man"
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            throw NetworkError.invalidURL
        }
        
        let endpoint = "\(Constants.baseURL)/search/movie?api_key=\(Constants.apiKey)&query=\(queryEncoded)&page=\(page)"
        
        guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let result = try JSONDecoder().decode(MovieResponse.self, from: data)
        return result.results
    }
    
    
}
