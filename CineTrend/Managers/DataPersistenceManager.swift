//
//  DataPersistenceManager.swift
//  CineTrend
//
//  Created by Trangptt on 31/12/25.
//

import UIKit
import CoreData

class DataPersistenceManager {
    
    static let shared = DataPersistenceManager()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Save
    func downloadMovieWith(model: Movie, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let item = MovieItem(context: context)
        
        // Gán dữ liệu từ API sang Database
        item.id = Int64(model.id)
        item.title = model.title ?? model.originalTitle
        item.overview = model.overview
        item.poster_path = model.posterPath
        item.vote_average = model.voteAverage
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Delete
    func deleteMovieWith(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Tìm phim đó trong DB
        let request: NSFetchRequest<MovieItem> = MovieItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int64(id))
        
        do {
            let results = try context.fetch(request)
            
            // Tìm thấy thì xoá
            if let objectToDelete = results.first {
                context.delete(objectToDelete)
                try context.save()
                completion(.success(()))
            } else {
                // Không tìm thấy phim để xoá
                completion(.failure(NSError(domain: "Delete Error", code: 404, userInfo: nil)))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // Check xem đã tim chưa
    func checkIsFavorite(id: Int) -> Bool {
        let request: NSFetchRequest<MovieItem> = MovieItem.fetchRequest()
        // Tìm xem có thằng nào có id bằng id truyền vào không
        request.predicate = NSPredicate(format: "id == %d", Int64(id))
        
        do {
            let count = try context.count(for: request)
            return count > 0 // Nếu đếm > 0 = có
        } catch {
            return false
        }
    }
    
    // Lấy tất cả phim
    func fetchingMoviesFromDataBase(completion: @escaping (Result<[MovieItem], Error>) -> Void) {
        let request: NSFetchRequest<MovieItem> = MovieItem.fetchRequest()
        do {
            let movies = try context.fetch(request)
            completion(.success(movies))
        } catch {
            completion(.failure(error))
        }
    }
}
