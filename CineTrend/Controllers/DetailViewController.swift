//
//  DetailViewController.swift
//  CineTrend
//
//  Created by Trangptt on 2/1/26.
//
import UIKit

class DetailViewController : UIViewController {
    var movie: Movie?
    private var trailerKey: String?
    private var castList: [Cast] = []
    private var similarMovies : [Movie] = []
    
    // Scroll view
    private let scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // ContentView
    private let contentView : UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    // Gradient overlay cho backdrop
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.withAlphaComponent(0.2).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradient.locations = [0.0, 0.7, 1.0]
        return gradient
    }()
    
    // Background image
    private let backImage : UIImageView = {
        let bi = UIImageView()
        bi.contentMode = .scaleAspectFill
        bi.clipsToBounds = true
        bi.backgroundColor = .systemGray5
        bi.translatesAutoresizingMaskIntoConstraints = false
        return bi
    }()
    
    // Container info
    private let infoCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // YTB Button
    private let youtubeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("▶ Watch Trailer", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        
        // Gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor(red: 0.6, green: 0.0, blue: 0.05, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 12
        btn.layer.insertSublayer(gradientLayer, at: 0)
        
        return btn
    }()
    
    // Tên phim
    private let titleLable : UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 28, weight: .bold)
        title.numberOfLines = 0
        title.textColor = .label
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Overview title với accent color
    private let subTitleLabel : UILabel = {
        let subTitle = UILabel()
        subTitle.text = "Overview"
        subTitle.font = .systemFont(ofSize: 20, weight: .bold)
        subTitle.textColor = .systemIndigo
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        return subTitle
    }()
    
    // Tóm tắt
    private let summary : UILabel = {
        let summary = UILabel()
        summary.numberOfLines = 0
        summary.font = .systemFont(ofSize: 16, weight: .regular)
        summary.textColor = .secondaryLabel
        summary.textAlignment = .justified
        summary.translatesAutoresizingMaskIntoConstraints = false
        
        return summary
    }()
    
    // Cast title với icon
    private let castTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "The Cast"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Danh sách diễn viên
    private let castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 110)
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Similar movies với icon
    private let similarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎬 Similar Movies"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemTeal
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // View All button
    private let viewAllButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View all →", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Danh sách phim tương đương
    private let similarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 240)
        layout.minimumLineSpacing = 16
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewAllButton.addTarget(self, action: #selector(handleViewAll), for: .touchUpInside)
        
        castCollectionView.register(CastCell.self, forCellWithReuseIdentifier: CastCell.identifier)
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
        
        let nib = UINib(nibName: "MovieCellCollectionViewCell", bundle: nil)
        similarCollectionView.register(nib, forCellWithReuseIdentifier: "MovieCellId")
        similarCollectionView.dataSource = self
        similarCollectionView.delegate = self
        
        youtubeButton.addTarget(self, action: #selector(didTapYoutubeButton), for: .touchUpInside)
        setUpUI()
        configureData()
        getTrailer()
        getCast()
        getSimilarMovie()
        setupNavigationBar()
        fetchMoviesDetail()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = backImage.bounds
        
        // Gradient cho YTB button
        if let gradientLayer = youtubeButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = youtubeButton.bounds
        }
    }
    
    @objc private func didTapYoutubeButton() {
        guard let key = trailerKey else { return }
        
        if let webURL = URL(string: "https://www.youtube.com/watch?v=\(key)") {
            UIApplication.shared.open(webURL)
        }
    }
    
    @objc private func handleViewAll (){
        let detaiGrid = MovieGridViewController()
        detaiGrid.movies = similarMovies
        detaiGrid.pageTitle = "Similar Movies"
        detaiGrid.listType = .none
        navigationController?.pushViewController(detaiGrid, animated: true)
    }
    
    // Fetch
    private func fetchMoviesDetail(){
        guard let movie = movie else{return}
        Task{
            do{
                let detail : MovieDetailResponse = try await NetworkManager.shared.request(.movieDetail(id: movie.id))
                DispatchQueue.main.async {
                    self.updateDetailUI(with: detail)
                }
            }catch{
                print("Lỗi fetch detail \(error)")
            }
        }
    }
    
    // Hàm cập nhật giao diện khi có dữ liệu mới
    private func updateDetailUI(with detail: MovieDetailResponse) {
        guard let movie = movie else {return}
        // Nối các thể loạ thành chuỗi
        var genreText = ""
        if let genres = detail.genres {
            genreText = genres.map { $0.name }.joined(separator: ", ")
        }
        
        // Xử lý thời lượng
        var timeText = ""
        if let runtime = detail.runtime {
            let hours = runtime / 60
            let minutes = runtime % 60
            timeText = "\(hours)h \(minutes)m"
        }
        let ratingValue = String(format: "%.1f", movie.voteAverage)
        let rating = "⭐ \(ratingValue) / 10"
        
        let releaseDate = movie.releaseDate ?? ""
        
        if !genreText.isEmpty && !timeText.isEmpty {
            self.ratingLabel.text = "\(releaseDate) | \(genreText) | \(timeText) | \(rating)"
        } else {
            self.ratingLabel.text = genreText.isEmpty ? "\(releaseDate) | \(genreText) | \(rating)" : "\(releaseDate) | \(timeText) | \(rating)"
        }
    }
    
    private func setUpUI(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backImage)
        backImage.layer.addSublayer(gradientLayer)
        
        contentView.addSubview(infoCard)
        infoCard.addSubview(titleLable)
        infoCard.addSubview(ratingLabel)
        infoCard.addSubview(youtubeButton)
        
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(summary)
        contentView.addSubview(castTitleLabel)
        contentView.addSubview(castCollectionView)
        contentView.addSubview(similarTitleLabel)
        contentView.addSubview(similarCollectionView)
        contentView.addSubview(viewAllButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            //Background img
            backImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            backImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backImage.heightAnchor.constraint(equalToConstant: 280),
            
            // Info Card
            infoCard.topAnchor.constraint(equalTo: backImage.bottomAnchor, constant: -40),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLable.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            titleLable.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 12),
            ratingLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            ratingLabel.heightAnchor.constraint(equalToConstant: 36),
            ratingLabel.widthAnchor.constraint(equalTo: youtubeButton.widthAnchor),
            
            // YTB button
            youtubeButton.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            youtubeButton.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            youtubeButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            youtubeButton.heightAnchor.constraint(equalToConstant: 50),
            youtubeButton.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20),
            
            subTitleLabel.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 27),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Overview
            summary.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 12),
            summary.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summary.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            castTitleLabel.topAnchor.constraint(equalTo: summary.bottomAnchor, constant: 24),
            castTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            castCollectionView.topAnchor.constraint(equalTo: castTitleLabel.bottomAnchor, constant: 12),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            castCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            similarTitleLabel.topAnchor.constraint(equalTo: castCollectionView.bottomAnchor, constant: 24),
            similarTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            viewAllButton.centerYAnchor.constraint(equalTo: similarTitleLabel.centerYAnchor),
            viewAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Similar movie
            similarCollectionView.topAnchor.constraint(equalTo: similarTitleLabel.bottomAnchor, constant: 12),
            similarCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            similarCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -16),
            similarCollectionView.heightAnchor.constraint(equalToConstant: 240),
            
            similarCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureData(){
        guard let movie = movie else {return}
        
        titleLable.text = movie.title ?? movie.originalTitle
        summary.text = movie.overview
        
        let path = movie.backDropPath ??  movie.posterPath ?? ""
        let url = Constants.imageBaseURL + path
        backImage.downloadImage(from: url)
    }
    
    // Fetch video, YTB button
    private func getTrailer() {
        guard let movie = movie else { return }
        
        Task {
            do {
                let videos : VideoResponse = try await NetworkManager.shared.request(.videos(movieId: movie.id))
                let trailer = videos.results.first { video in
                    return video.site == "YouTube" && (video.type == "Trailer" || video.type == "Teaser")
                }
                
                if let trailer = trailer {
                    self.trailerKey = trailer.key
                    DispatchQueue.main.async {
                        self.youtubeButton.isHidden = false
                    }
                }
            } catch {
                print("Lỗi lấy trailer: \(error)")
            }
        }
    }
    
    // Icon tim
    private func setupNavigationBar() {
        guard let movie = movie else { return }
        let isFav = DataPersistenceManager.shared.checkIsFavorite(id: movie.id)
        
        let imageName = isFav ? "heart.fill" : "heart"
        let color: UIColor = isFav ? .systemPink : .label
        
        let heartButton = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: #selector(didTapFavorite)
        )
        heartButton.tintColor = color
        navigationItem.rightBarButtonItem = heartButton
    }
    
    // Xử lý thả tim
    @objc private func didTapFavorite() {
        guard let movie = movie else { return }
        let isAlreadyFav = DataPersistenceManager.shared.checkIsFavorite(id: movie.id)
        
        if isAlreadyFav {
            DataPersistenceManager.shared.deleteMovieWith(id: movie.id) { [weak self] result in
                switch result {
                case .success():
                    print("Đã xoá khỏi Yêu thích")
                    NotificationCenter.default.post(name: NSNotification.Name("changedDatabase"), object: nil)
                    DispatchQueue.main.async {
                        self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
                        self?.navigationItem.rightBarButtonItem?.tintColor = .label
                    }
                case .failure(let error):
                    print("Lỗi xoá: \(error)")
                }
            }
        } else {
            DataPersistenceManager.shared.downloadMovieWith(model: movie) { [weak self] result in
                switch result {
                case .success():
                    print("Đã lưu vào Yêu thích")
                    NotificationCenter.default.post(name: NSNotification.Name("changedDatabase"), object: nil)
                    DispatchQueue.main.async {
                        self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
                        self?.navigationItem.rightBarButtonItem?.tintColor = .systemPink
                    }
                case .failure(let error):
                    print("Lỗi lưu: \(error)")
                }
            }
        }
    }
    
    // Lấy dsach dvien
    private func getCast() {
        guard let movie = movie else { return }
        Task {
            do {
                let cast : CreditsResponse = try await NetworkManager.shared.request(.credits(movieId: movie.id))
                self.castList = Array(cast.cast.prefix(10))
                DispatchQueue.main.async {
                    self.castCollectionView.reloadData()
                }
            } catch {
                print("Lỗi lấy diễn viên: \(error)")
            }
        }
    }
    
    // Lấy dsach phim tương tự
    private func getSimilarMovie(){
        guard let movie = movie else {return}
        Task{
            do{
                let similar : MovieResponse = try await NetworkManager.shared.request(.similar(id: movie.id))
                self.similarMovies = Array(similar.results.filter{ $0.posterPath != nil})
                DispatchQueue.main.async {
                    self.similarCollectionView.reloadData()
                }
            }catch{
                print("Loi lay similar: \(error)")
            }
        }
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == castCollectionView{
            return castList.count
        }else{
            return similarMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == castCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCell.identifier, for: indexPath) as? CastCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: castList[indexPath.row])
            return cell
        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellId", for: indexPath) as? MovieCellCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.configure(with: similarMovies[indexPath.row], isBig: false)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == similarCollectionView{
            let selectedMovie: Movie = similarMovies[indexPath.row]
            let detailVC = DetailViewController()
            detailVC.movie = selectedMovie
            navigationController?.pushViewController(detailVC, animated: true)
        }else if collectionView == castCollectionView {
            let selectedPerson = castList[indexPath.row]
            let detaiPerson = PersonViewController()
            detaiPerson.personId = selectedPerson.id
            navigationController?.pushViewController(detaiPerson, animated: true)
        }
    }
}
