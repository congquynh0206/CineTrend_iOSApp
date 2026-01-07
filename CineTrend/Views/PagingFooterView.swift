//
//  PagingFooterView.swift
//  CineTrend
//
//  Created by Trangptt on 31/12/25.
//

import UIKit

class PagingFooterView: UICollectionReusableView {
    static let reuseIdentifier = "PagingFooterView"
    
    let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .systemRed // Màu chấm đang chọn
        pc.pageIndicatorTintColor = .systemGray // Màu chấm chưa chọn
        pc.isUserInteractionEnabled = false // Không cho bấm
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pageControl)
        
        // Căn giữa
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Nhận số lượng trang và trang hiện tại
    func configure(numberOfPages: Int, currentPage: Int) {
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage
    }
}
