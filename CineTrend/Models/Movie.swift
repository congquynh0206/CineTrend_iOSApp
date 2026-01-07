//
//  Movies.swift
//  CineTrend
//
//  Created by Trangptt on 28/12/25.
//
import Foundation


struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int
    let title : String?
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let backDropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let popularity : Double?
    
    // Map sang tên của json
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case overview
        case backDropPath = "backdrop_path"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case popularity
    }
}

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let id: String
    let key: String    // Dùng để ghép thành link YouTube
    let name: String
    let site: String
    let type: String
}


// Detail
struct MovieDetailResponse: Codable {
    let id: Int
    let runtime: Int?
    let genres: [Genre]?
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id, runtime, genres
        case releaseDate = "release_date"
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}
