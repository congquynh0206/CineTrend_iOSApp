//
//  PersonViewController.swift
//  CineTrend - Modern Design
//
//  Created by Trangptt on 5/1/26.
//

import UIKit

class PersonViewController : UIViewController{
    var personId : Int = 0
    private var movies : [Movie] = []
    private var isExpand = false
    
    // Scroll View
    private let scrollView : UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // ContentView
    private let contentView : UIView = {
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Background Image
    private let headerImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    // Gradient overlay cho header
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.withAlphaComponent(0.3).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradient.locations = [0.0, 0.7 , 1.0]
        return gradient
    }()
    
    // Container info
    private let profileCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Avatar
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.white.cgColor
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Tên
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Job
    private let jobLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Bio label
    private let bioTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Biography"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemIndigo
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Bio
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSummary))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    // Known for với icon
    private let knownForTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎬 Known for"
        label.textColor = .systemTeal
        label.font = .systemFont(ofSize: 20, weight: .bold)
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
    
    // Phim collection view
    private let moviesCollectionView : UICollectionView = {
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
        setupUI()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = headerImageView.bounds
    }
    
    // Xử lý thu, mở bio
    @objc private func didTapSummary(){
        isExpand.toggle()
        bioLabel.numberOfLines = isExpand ? 0 : 3
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Xử lý view all button
    @objc private func handleViewAll (){
        let detaiGrid = MovieGridViewController()
        detaiGrid.movies = movies
        detaiGrid.pageTitle = "Filmography"
        detaiGrid.listType = .none
        navigationController?.pushViewController(detaiGrid, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerImageView)
        headerImageView.layer.addSublayer(gradientLayer)
        
        contentView.addSubview(profileCard)
        profileCard.addSubview(avatarImageView)
        profileCard.addSubview(nameLabel)
        profileCard.addSubview(jobLabel)
        
        contentView.addSubview(bioTitleLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(knownForTitleLabel)
        contentView.addSubview(moviesCollectionView)
        contentView.addSubview(viewAllButton)
        
        // Setup CollectionView
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        let nib = UINib(nibName: "MovieCellCollectionViewCell", bundle: nil)
        moviesCollectionView.register(nib, forCellWithReuseIdentifier: "MovieCellId")
        
        NSLayoutConstraint.activate([
            // ScrollView full màn hình
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header Image
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 280),
            
            // Profile Card
            profileCard.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -60),
            profileCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Avatar
            avatarImageView.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 110),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Name
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 10),
            
            // Job Container
            jobLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            jobLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            jobLabel.heightAnchor.constraint(equalToConstant: 36),
            
            jobLabel.leadingAnchor.constraint(equalTo: jobLabel.leadingAnchor, constant: 12),
            jobLabel.trailingAnchor.constraint(equalTo: jobLabel.trailingAnchor, constant: -12),
            jobLabel.centerYAnchor.constraint(equalTo: jobLabel.centerYAnchor),
            
            profileCard.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            
            // Biography Title
            bioTitleLabel.topAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: 27),
            bioTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bioTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Bio
            bioLabel.topAnchor.constraint(equalTo: bioTitleLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Known for
            knownForTitleLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 24),
            knownForTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // View All button
            viewAllButton.centerYAnchor.constraint(equalTo: knownForTitleLabel.centerYAnchor),
            viewAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // List phim
            moviesCollectionView.topAnchor.constraint(equalTo: knownForTitleLabel.bottomAnchor, constant: 12),
            moviesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            moviesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            moviesCollectionView.heightAnchor.constraint(equalToConstant: 240),
            
            // Neo đáy để ScrollView hoạt động
            moviesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // Fetch Data
    private func fetchData() {
        Task {
            do {
                // Gọi song song 2 API Info, Movies
                async let personDetail : Person = NetworkManager.shared.request(.personDetail(id: personId))
                async let personMovies : PersonMovieCreditsResponse = NetworkManager.shared.request(.personMovieCredits(id: personId))
                
                let (person, moviesResponse) = try await (personDetail, personMovies)
                self.movies = moviesResponse.cast.filter{$0.posterPath != nil}.sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
                
                DispatchQueue.main.async {
                    self.updateUI(with: person)
                    self.moviesCollectionView.reloadData()
                    
                    // Lấy ảnh của phim nổi tiếng nhất làm background img
                    if let bestMovie = self.movies.first, let backdrop = bestMovie.backDropPath {
                        let url = Constants.imageBaseURL + backdrop
                        self.headerImageView.downloadImage(from: url)
                    }
                }
            } catch {
                print("Lỗi load profile: \(error)")
            }
        }
    }
    

    // update ui
    private func updateUI(with person: Person) {
        nameLabel.text = person.name
        jobLabel.text = person.knownForDepartment
        bioLabel.text = person.biography.isEmpty ? "No biography available." : person.biography
        
        if let path = person.profilePath {
            avatarImageView.downloadImage(from: Constants.imageBaseURL + path)
        }
    }
    
}

// Datasource, delegate
extension PersonViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    // Bấm vào phim thì mở màn hình Detail
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        detailVC.movie = movies[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
