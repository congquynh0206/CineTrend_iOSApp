//
//  FavoritesViewController.swift
//  CineTrend
//
//  Created by Trangptt on 2/1/26.
//
import UIKit

class FavoritesViewController : UIViewController{
    
    private var movies : [MovieItem] = []
    
    private let collectionView : UICollectionView = {
        let cv = UICollectionViewFlowLayout()
        let itemWidth = (UIScreen.main.bounds.width) / 3 - 10
        cv.itemSize = CGSize(width: itemWidth, height: itemWidth * 2)
        cv.minimumLineSpacing = 10
        cv.minimumInteritemSpacing = 5
        cv.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let clv = UICollectionView(frame: .zero, collectionViewLayout: cv)
        clv.backgroundColor = .systemBackground
        return clv
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favourites"
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "MovieCellCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MovieCellId")
        
        // Nếu bên Detail có thay dodoir thì bên này tự cập nhật
        NotificationCenter.default.addObserver(forName: NSNotification.Name("changedDatabase"), object: nil, queue: .main) { [weak self] _ in
            self?.fetchLocalStorageForDownload()
        }
    }
    
    
    override func viewWillAppear (_ animated : Bool) {
        super.viewWillAppear(animated)
        fetchLocalStorageForDownload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    
    
    // Load du lieu tu db
    private func fetchLocalStorageForDownload(){
        DataPersistenceManager.shared.fetchingMoviesFromDataBase { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movies = movies
                DispatchQueue.main.async{
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
}

extension FavoritesViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCellId", for: indexPath) as? MovieCellCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func collectionView (_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let detailVc = DetailViewController()
        
        let item = movies[indexPath.row]
        let movie = Movie(
            id: Int(item.id),
            title: item.title,
            originalTitle: item.title,
            overview: item.overview,
            posterPath: item.poster_path,
            backDropPath: nil,
            releaseDate: nil,
            voteAverage: item.vote_average,
            popularity: nil
        )
        detailVc.movie = movie
        
        navigationController?.pushViewController(detailVc, animated: true)
    }
}
