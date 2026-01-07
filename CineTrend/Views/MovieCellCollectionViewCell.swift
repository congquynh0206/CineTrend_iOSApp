//
//  MovieCellCollectionViewCell.swift
//  CineTrend
//
//  Created by Trangptt on 30/12/25.
//

import UIKit

class MovieCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var posterHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    private var currentURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 12
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.backgroundColor = .systemGray5
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        posterImageView.image = nil
    }
    
    private func loadImage(from urlString: String) {
        self.currentURL = urlString
        
        // Bắt đầu tải thì xoá ảnh cũ
        self.posterImageView.image = nil
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Kiểm tra có đúng url hiện tại không
                if self.currentURL == urlString {
                    
                    if let data = data, error == nil, let image = UIImage(data: data) {
                        self.posterImageView.image = image
                    }
                }
            }
        }.resume()
    }

    // config
    func configure(with movie: Movie, isBig : Bool) {
        let fullURL = Constants.imageBaseURL + (movie.posterPath ?? "")
        self.loadImage(from: fullURL)
        
        self.titleLabel.text = movie.originalTitle
        if isBig {
            self.titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
            self.posterHeightConstraint = self.posterHeightConstraint.setMultiplier(multiplier: 0.90)
        } else {
            self.titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            self.posterHeightConstraint = self.posterHeightConstraint.setMultiplier(multiplier: 0.80)
        }
        self.layoutIfNeeded()
    }
    
    func configure(with model : MovieItem){
        let fullURL = Constants.imageBaseURL + (model.poster_path ?? "")
        self.loadImage(from: fullURL)
        
        self.titleLabel.text = model.title
        self.titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        self.titleLabel.textAlignment = .center
        self.posterHeightConstraint = self.posterHeightConstraint.setMultiplier(multiplier: 0.80)
    }
}

extension NSLayoutConstraint {
    // Hàm giúp thay đổi multiplier
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
