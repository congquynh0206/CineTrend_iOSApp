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
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 12
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.backgroundColor = .systemGray5
    }

    // Hàm nhận dữ liệu từ ViewController để hiển thị
    func configure(with movie: Movie, isBig : Bool) {
        let fullURL = Constants.imageBaseURL + (movie.posterPath ?? "")
        
        self.posterImageView.downloadImage(from: fullURL)
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
}

extension NSLayoutConstraint {
    // Hàm này giúp thay đổi multiplier
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
