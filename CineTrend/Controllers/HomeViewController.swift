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

class HomeViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var searchTimer: Timer?
    
    private var bannerTimer : Timer?
    private var currentBannerIndex = 0

    var trendingMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var upcomingMovies: [Movie] = []
    

    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(loadingSpinner)
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        configureCollectionView()
        fetchData()
        setupSearchController()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Dừng timer khi màn hình bị ẩn
        stopBannerAutoScroll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Chạy lại timer khi màn hình hiện lên
        if !trendingMovies.isEmpty {
            startBannerAutoScroll()
        }
    }
    
    //Loading
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .systemGray
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    // Search
    func setupSearchController() {
        // Tạo màn hình kết quả
        let searchResultsVC = SearchResultsViewController()
        
        // Gán delegate để khi bấm vào phim ở màn search thì màn Home biết để push đi
        searchResultsVC.delegate = self
        
        // Tạo Search Controller chứa màn hình kết quả
        let searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Movies"
        
        // Gắn vào Navigation Bar
        navigationItem.searchController = searchController
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
        // Đăng ký Footer
        collectionView.register(PagingFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: PagingFooterView.reuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
    }
    
    // Hàm tạo layout (Banner to + List nhỏ)
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
        //let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(600))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(480))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section - hàng
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        
        // Header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        // Footer
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        
        section.boundarySupplementaryItems = [header, footer]
        
        // To ở giữa, nhỏ 2 bên, hàm này cập nhật liên tục
        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, offset, env) in
            guard let self = self else { return }
            
            // Toạ độ tâm thực tế
            let centerX = offset.x + (env.container.contentSize.width / 2)
            
            for item in visibleItems {
                // Chỉ apply hiệu ứng cho Cell , bỏ qua Header/Footer
                guard item.representedElementCategory == .cell else { continue }
                
                // Tính khoảng cách từ tâm item đến tâm màn hình
                let distanceFromCenter = abs(item.frame.midX - centerX)
                
                // Nhỏ nhất chỉ 0.85
                let minScale: CGFloat = 0.85
                let containerWidth = env.container.contentSize.width
                
                // Càng xa tâm càng nhỏ, càng gần tâm càng to
                let scale = max(minScale, 1 - (distanceFromCenter / containerWidth) * 0.2)
                
                // Áp dụng transform, biến đổi thuộc tính cell ngay lập tức
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                
            }
            // Vì groupSize width = 0.8 nên phải nhân 0.8
            let bannerWidth = env.container.contentSize.width * 0.8
            let page = Int(round(offset.x / bannerWidth))
            
            // Update biến currentBannerIndex để Timer chạy đúng
            if page >= 0 && page < self.trendingMovies.count {
                self.currentBannerIndex = page
            }
            
            // Cập nhật footer
            if let footerItem = visibleItems.first(where: { $0.representedElementKind == UICollectionView.elementKindSectionFooter }) {
                if let footerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: footerItem.indexPath) as? PagingFooterView {
                    footerView.configure(numberOfPages: self.trendingMovies.count, currentPage: page)
                }
            }
        }
        
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
        DispatchQueue.main.async {
            self.loadingSpinner.startAnimating()
            self.collectionView.isHidden = true
        }
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
                    self.loadingSpinner.stopAnimating()
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    
                    // Scroll ra giữa khi vừa fetch
                    if !self.trendingMovies.isEmpty {
                        let midIndex = self.trendingMovies.count / 2
                        let indexPath = IndexPath(item: midIndex, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                        self.startBannerAutoScroll()
                    }
                }
            } catch {
                print("Lỗi tải dữ liệu: \(error)")
                DispatchQueue.main.async {
                    self.loadingSpinner.stopAnimating()
                    let alert = UIAlertController(title: "Network Error", message: "Not connect.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self]_ in
                        self?.fetchData()
                    }))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // Thời gian scroll banner
    func startBannerAutoScroll(){
        stopBannerAutoScroll()
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true){ [weak self] _ in
            self?.scrollToNextBanner()
        }
    }
    
    // Dừng scroll
    func stopBannerAutoScroll(){
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    
    // Scroll đến bannẻ tiếp theo
    func scrollToNextBanner(){
        guard !trendingMovies.isEmpty else {return}
        let nextIndex = currentBannerIndex + 1
        if nextIndex < trendingMovies.count {
            currentBannerIndex = nextIndex
            let indexPath = IndexPath(item: currentBannerIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
        }else {
            currentBannerIndex = 0
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// DataSource - Delegate
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        // Xử lý Header
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else {
                return UICollectionReusableView()
            }
            
            guard let sectionType = BrowseSection(rawValue: indexPath.section) else { return header }
            // Set tên Header
            header.titleLabel.text = sectionType.title
            
            header.onViewAllTap = { [weak self] in
                guard let self = self else { return }
                
                // Khởi tạo màn hình View All
                let gridVC = MovieGridViewController()
                
                // Truyền dữ liệu tương ứng với section
                switch sectionType {
                case .trending:
                    gridVC.movies = self.trendingMovies
                    gridVC.pageTitle = "Trending Now"
                case .nowPlaying:
                    gridVC.movies = self.nowPlayingMovies
                    gridVC.pageTitle = "Now Playing"
                case .upcoming:
                    gridVC.movies = self.upcomingMovies
                    gridVC.pageTitle = "Upcoming Movies"
                }
                
                // Đẩy sang màn hình mới 
                self.navigationController?.pushViewController(gridVC, animated: true)
            }
            return header
        }
        
        // Xử lý Footer, chỉ hiện ở Trending (Section 0)
        if kind == UICollectionView.elementKindSectionFooter && indexPath.section == 0 {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PagingFooterView.reuseIdentifier, for: indexPath) as? PagingFooterView else {
                return UICollectionReusableView()
            }
            // Tổng số trang = số phim Trending
            footer.configure(numberOfPages: trendingMovies.count, currentPage: 0)
            return footer
        }
        
        return UICollectionReusableView()
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

extension HomeViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        //  Hủy hẹn giờ cũ
        searchTimer?.invalidate()
        
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.count >= 3, // Chỉ search khi gõ trên 3 kí tự
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            
            // Nếu xoá hết chữ thì xoá list kết quả đi
            if let resultsController = searchController.searchResultsController as? SearchResultsViewController {
                resultsController.movies = []
                resultsController.searchCollectionView.reloadData()
            }
            return
        }
        
        // Tạo một hẹn giờ mới (Debounce)
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            
            // Gọi api
            print("Đang search: \(query)")
            
            Task {
                do {
                    let movies = try await NetworkManager.shared.searchMovies(query: query)
                    
                    // Cập nhật UI
                    DispatchQueue.main.async {
                        resultsController.movies = movies
                        resultsController.searchCollectionView.reloadData()
                    }
                } catch {
                    print("Lỗi search: \(error)")
                }
            }
        }
    }
}
// Xử lý khi bấm vào phim ở màn Search (Delegate)
extension HomeViewController: SearchResultsDelegate {
    func didTapItem(_ movie: Movie) {
        let detailVC = DetailViewController()
        detailVC.movie = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
