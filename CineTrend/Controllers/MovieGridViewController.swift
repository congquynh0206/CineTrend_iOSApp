//
//  MovieGridViewController.swift
//  CineTrend
//
//  Created by Trangptt on 31/12/25.
//


import UIKit

enum MovieListType {
    case trending
    case nowPlaying
    case upcoming
    case none
}

class MovieGridViewController: UIViewController {

    // Dữ liệu phim
    var movies: [Movie] = []
    var pageTitle: String = ""
    
    var listType: MovieListType = .none     // Loại dsach hiện tại
    private var currentPage = 1
    private var isLoadingMore = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        // Chia 3 cột
        let itemWidth = UIScreen.main.bounds.width / 3 - 10
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 2)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        self.title = pageTitle

        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        let nib = UINib(nibName: "MovieCellCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MovieCellId")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // Gọi API load thêm
    private func loadMoreData(){
        guard !isLoadingMore else{
            return
        }
        isLoadingMore = true
        let nextPage = currentPage + 1
        Task{
            do{
                var newMovies : [Movie] = []
                switch listType {
                case .trending:
                    newMovies = try await NetworkManager.shared.getTrendingMovies(page: nextPage)
                case .nowPlaying:
                    newMovies = try await NetworkManager.shared.getNowPlayingMovies(page: nextPage)
                case .upcoming:
                    newMovies = try await NetworkManager.shared.getUpcomingMovies(page: nextPage)
                case .none:
                    break
                }
                DispatchQueue.main.async {
                    // heets phim
                    if newMovies.isEmpty{
                        self.isLoadingMore = false
                        return
                    }
                    self.movies.append(contentsOf: newMovies)
                    self.currentPage = nextPage
                    self.isLoadingMore = false
                    self.collectionView.reloadData()
                }
            }catch {
                print("Lỗi tải thêm trang: \(error)")
                self.isLoadingMore = false
            }
        }
    }
}

extension MovieGridViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellId", for: indexPath) as? MovieCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: movies[indexPath.row], isBig: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Khi bấm vào phim trong list View All thì chuyển sang Detail
        let detailVC = DetailViewController()
        detailVC.movie = movies[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = collectionView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        // Nội dung ngắn quá thì không cần check
        guard contentHeight > screenHeight else { return }
        
        // Khi lướt đến cách đáy 100pt thì gọi hàm tải thêm
        if position > (contentHeight - screenHeight - 100) {
            loadMoreData()
        }
    }
}
