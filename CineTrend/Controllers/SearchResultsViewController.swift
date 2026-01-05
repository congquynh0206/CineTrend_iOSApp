//
//  SearchResultsViewController.swift
//  CineTrend
//
//  Created by Trangptt on 31/12/25.
//

import UIKit

// Protocol để báo cho Home biết là đã bấm vào phim nào trong lúc search
protocol SearchResultsDelegate: AnyObject {
    func didTapItem(_ movie: Movie)
}

class SearchResultsViewController: UIViewController {
    
    public var movies: [Movie] = []
    public weak var delegate: SearchResultsDelegate?
    public var isLoadingMore = false
    public var currentPage = 1
    public var searchQuery = ""
    
    public let searchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = UIScreen.main.bounds.width / 3 - 10
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 2) // Chia 3 cột
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(searchCollectionView)
        
        // Đăng ký Cell cũ để dùng lại
        let nib = UINib(nibName: "MovieCellCollectionViewCell", bundle: nil)
        searchCollectionView.register(nib, forCellWithReuseIdentifier: "MovieCellId")
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchCollectionView.frame = view.bounds
    }
    
    public func performNewSearch(with query: String){
        self.searchQuery = query
        self.currentPage = 1
        self.movies.removeAll()
        self.isLoadingMore = false
        self.searchCollectionView.reloadData()
        loadMoreData()
    }
    
    private func loadMoreData(){
        guard !isLoadingMore else{return}
        isLoadingMore = true
        Task{
            do{
                var newMovies : [Movie] = []
                newMovies = try await NetworkManager.shared.searchMovies(query: searchQuery, page: currentPage)
                print("Load lần : \(currentPage) - tổng phim: \(movies.count)")
                DispatchQueue.main.async {
                    if !newMovies.isEmpty {
                        self.currentPage += 1
                    }
                    
                    self.movies.append(contentsOf: newMovies)
                    self.isLoadingMore = false
                    self.searchCollectionView.reloadData()
                }
            }catch{
                print("Looi seach: \(error)")
                self.isLoadingMore = false
            }
        }
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
        // Khi bấm vào phim thì báo cho cho home biết để chuyển màn hình
        delegate?.didTapItem(movies[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = searchCollectionView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        if position > (contentHeight - screenHeight - 100) {
            guard !isLoadingMore else { return }
            loadMoreData()
        }
    }
}
