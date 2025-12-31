//
//  ViewController.swift
//  CineTrend
//
//  Created by Trangptt on 26/12/25.
//

import UIKit

// Các loại section
enum BrowseSection: Int {
    case trending = 0
    case nowPlaying = 1
    case upcoming = 2
    
    // Hàm lấy tiêu đề cho từng mục
    var title: String {
        switch self {
        case .trending: return "Trending Now"
        case .nowPlaying: return "Now Playing"
        case .upcoming: return "Upcoming Movies"
        }
    }
}

class ViewController: UIViewController {

    private var collectionView: UICollectionView!

    var trendingMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var upcomingMovies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureCollectionView()
        fetchData()
    }
    

    // Cấu hình view
    func configureCollectionView() {
        let layout = createCompositionalLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        
        // Đăng ký Cell
        let nib = UINib(nibName: "MovieCellCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MovieCellId")
        
        // Đăng ký Header
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    // Hàm tạo layout phức tạp (Banner to + List nhỏ)
    func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionType = BrowseSection(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .trending:
                return self.createBannerSection()
            case .nowPlaying, .upcoming:
                return self.createHorizontalSection()
            }
        }
    }
    
    // Layout Banner to
    func createBannerSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(600))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section - hàng
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging // Vuốt từng tấm một
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
        
        // Header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // Layout nhỏ
    func createHorizontalSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(240))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous // Vuốt mượt
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 30, trailing: 10)
        
        // Header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // Fetch Data
    func fetchData() {
        Task {
            do {
                // Gọi 3 API cùng lúc
                async let trending = NetworkManager.shared.getTrendingMovies()
                async let nowPlaying = NetworkManager.shared.getNowPlayingMovies()
                async let upcoming = NetworkManager.shared.getUpcomingMovies()
                
                // Chờ cả 3 xong
                let (trend, now, up) = try await (trending, nowPlaying, upcoming)
                
                self.trendingMovies = trend
                self.nowPlayingMovies = now
                self.upcomingMovies = up
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("Lỗi tải dữ liệu: \(error)")
            }
        }
    }
}

// DataSource - Delegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Số lượng Section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    // Số lượng Item trong mỗi Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch BrowseSection(rawValue: section) {
        case .trending: return trendingMovies.count
        case .nowPlaying: return nowPlayingMovies.count
        case .upcoming: return upcomingMovies.count
        default: return 0
        }
    }
    
    // Hiển thị Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellId", for: indexPath) as? MovieCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movie: Movie
        var isBig : Bool
        switch BrowseSection(rawValue: indexPath.section) {
        case .trending:
            movie = trendingMovies[indexPath.row]
            isBig = true
        case .nowPlaying:
            movie = nowPlayingMovies[indexPath.row]
            isBig = false
        case .upcoming:
            movie = upcomingMovies[indexPath.row]
            isBig = false
        default: return UICollectionViewCell()
        }
        
        cell.configure(with: movie, isBig: isBig)
        return cell
    }
    
    // Hiển thị Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        if let sectionType = BrowseSection(rawValue: indexPath.section) {
            header.titleLabel.text = sectionType.title
        }
        
        return header
    }
    
    // Xử lý khi bấm vào phim
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie: Movie
        
        switch BrowseSection(rawValue: indexPath.section) {
        case .trending: selectedMovie = trendingMovies[indexPath.row]
        case .nowPlaying: selectedMovie = nowPlayingMovies[indexPath.row]
        case .upcoming: selectedMovie = upcomingMovies[indexPath.row]
        default: return
        }
        
        let detailVC = DetailViewController()
        detailVC.movie = selectedMovie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
