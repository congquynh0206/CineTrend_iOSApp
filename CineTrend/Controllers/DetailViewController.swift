//
//  DetailViewController.swift
//  CineTrend
//
//  Created by Trangptt on 30/12/25.
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
    
    
    //Ảnh bìa
    private let backImage : UIImageView = {
        let bi = UIImageView()
        bi.contentMode = .scaleAspectFill
        bi.clipsToBounds = true
        bi.backgroundColor = .systemGray5
        bi.translatesAutoresizingMaskIntoConstraints = false
        return bi
    }()
    
    // Button
    private let youtubeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Watch Trailer on YouTube", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()
    
    // Tên phim
    private let titleLable : UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 24, weight: .bold)
        title.numberOfLines = 0
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
   
    // Rating
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Sub title
    private let subTitleLabel : UILabel = {
        let subTitle = UILabel()
        subTitle.text = "OverView"
        subTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        subTitle.textColor = .secondaryLabel
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        return subTitle
    }()
    
    //Tóm tắt
    private let summary : UILabel = {
        let summary = UILabel()
        summary.numberOfLines = 0
        summary.font = .systemFont(ofSize: 16, weight: .regular)
        summary.textColor = .label
        summary.textAlignment = .justified
        summary.translatesAutoresizingMaskIntoConstraints = false
        return summary
    }()
    
    
    private let castTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "The Cast"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
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
    
    private let similarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Similar Movies"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Danh sách diễn viên
    private let similarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 220)
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
    }
    
    // Hàm xử lý khi bấm nút
    @objc private func didTapYoutubeButton() {
        guard let key = trailerKey else { return }
        
        if let webURL = URL(string: "https://www.youtube.com/watch?v=\(key)") {
            UIApplication.shared.open(webURL)
        }
    }
    
    private func setUpUI(){
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backImage)
        contentView.addSubview(youtubeButton)
        contentView.addSubview(titleLable)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(summary)
        contentView.addSubview(castTitleLabel)
        contentView.addSubview(castCollectionView)
        contentView.addSubview(similarTitleLabel)
        contentView.addSubview(similarCollectionView)
        
        NSLayoutConstraint.activate([
            // scroll
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // content
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            
            // Ảnh bìa
            backImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            backImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backImage.heightAnchor.constraint(equalToConstant: 220),
            
            // Button
            youtubeButton.topAnchor.constraint(equalTo: backImage.bottomAnchor, constant: 10),
            youtubeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            youtubeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            youtubeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Tên phim
            titleLable.topAnchor.constraint(equalTo: youtubeButton.bottomAnchor, constant: 20),
            titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Nội dung phụ
            subTitleLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 20),
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Summary
            summary.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 8),
            summary.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summary.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            castTitleLabel.topAnchor.constraint(equalTo: summary.bottomAnchor, constant: 16),
            castTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            castCollectionView.topAnchor.constraint(equalTo: castTitleLabel.bottomAnchor, constant: 10),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            castCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            similarTitleLabel.topAnchor.constraint(equalTo: castCollectionView.bottomAnchor, constant: 24),
            similarTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            similarCollectionView.topAnchor.constraint(equalTo: similarTitleLabel.bottomAnchor, constant: 10),
            similarCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            similarCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -16),
            similarCollectionView.heightAnchor.constraint(equalToConstant: 220),
            
            similarCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    
    private func configureData(){
        guard let movie = movie else {return}
        
        titleLable.text = movie.title ?? movie.originalTitle
        summary.text = movie.overview
        
        let ratingValue = String(format: "%.1f", movie.voteAverage)
        ratingLabel.text = "★ \(ratingValue) / 10 "
        
        let path = movie.backDropPath ??  movie.posterPath ?? ""
        let url = Constants.imageBaseURL + path
        backImage.downloadImage(from: url)
    }
    
    private func getTrailer() {
        guard let movie = movie else { return }
        
        Task {
            do {
                let videos = try await NetworkManager.shared.getMovieVideos(movieId: movie.id)
                
                // Lọc video
                let trailer = videos.first { video in
                    return video.site == "YouTube" && (video.type == "Trailer" || video.type == "Teaser")
                }
                
                // Nếu tìm thấy trailer
                if let trailer = trailer {
                    self.trailerKey = trailer.key // Lưu key
                    
                    // Hiện nút lên
                    DispatchQueue.main.async {
                        self.youtubeButton.isHidden = false
                    }
                }
            } catch {
                print("Lỗi lấy trailer: \(error)")
            }
        }
    }
    
    // Yêu thích
    
    private func setupNavigationBar() {
        // Kiểm tra xem phim này đã tim chưa để hiện icon tương ứng
        guard let movie = movie else { return }
        let isFav = DataPersistenceManager.shared.checkIsFavorite(id: movie.id)
        
        let imageName = isFav ? "heart.fill" : "heart" // Đỏ hoặc Rỗng
        let color: UIColor = isFav ? .systemRed : .label
        
        let heartButton = UIBarButtonItem(
            image: UIImage(systemName: imageName),
            style: .plain,
            target: self,
            action: #selector(didTapFavorite)
        )
        heartButton.tintColor = color
        navigationItem.rightBarButtonItem = heartButton
    }
    
    @objc private func didTapFavorite() {
        guard let movie = movie else { return }
        
        // Kiểm tra trạng thái hiện tại
        let isAlreadyFav = DataPersistenceManager.shared.checkIsFavorite(id: movie.id)
        
        if isAlreadyFav {
            // Nếu đang tim thì xoá
            DataPersistenceManager.shared.deleteMovieWith(id: movie.id) { [weak self] result in
                switch result {
                case .success():
                    print("Đã xoá khỏi Yêu thích")
                    // Update lại icon thành rỗng
                    DispatchQueue.main.async {
                        self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
                        self?.navigationItem.rightBarButtonItem?.tintColor = .label
                    }
                case .failure(let error):
                    print("Lỗi xoá: \(error)")
                }
            }
            
        } else {
            // Nếu chưa tim thì lưu
            DataPersistenceManager.shared.downloadMovieWith(model: movie) { [weak self] result in
                switch result {
                case .success():
                    print("Đã lưu vào Yêu thích")
                    // Update lại icon thành tim đỏ
                    DispatchQueue.main.async {
                        self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
                        self?.navigationItem.rightBarButtonItem?.tintColor = .systemRed
                    }
                case .failure(let error):
                    print("Lỗi lưu: \(error)")
                }
            }
        }
    }
    
    // Lấy danh sách dvien
    private func getCast() {
        guard let movie = movie else { return }
        Task {
            do {
                let cast = try await NetworkManager.shared.getMovieCredits(movieId: movie.id)
                // Lấy tối đa 10 diễn viên
                self.castList = Array(cast.prefix(10))
                DispatchQueue.main.async {
                    self.castCollectionView.reloadData()
                }
            } catch {
                print("Lỗi lấy diễn viên: \(error)")
            }
        }
    }
    
    // Lấy dsach phim liên quan
    private func getSimilarMovie(){
        guard let movie = movie else {return}
        Task{
            do{
                let similar = try await NetworkManager.shared.getSimilarMoives(movieId: movie.id)
                self.similarMovies = Array(similar)
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
    
    // Xử lý khi bấm vào phim
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == similarCollectionView{
            let selectedMovie: Movie = similarMovies[indexPath.row]
            let detailVC = DetailViewController()
            detailVC.movie = selectedMovie
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

