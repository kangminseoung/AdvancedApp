//
//  BookDetaViewController.swift
//  Advanced
//
//  Created by 강민성 on 12/30/24.
//

import UIKit
import SnapKit

class SearchCollectionViewCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 셀 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        priceLabel.text = nil
    }

    private func setupUI() {
        contentView.backgroundColor = .white // 배경색 설정
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 8

        // Title Label
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1 // 한 줄로 제한
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.right.equalToSuperview().inset(8) // 좌우 여백 추가
        }

        // Price Label
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .gray
        priceLabel.numberOfLines = 1 // 한 줄로 제한
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().offset(-8) // 레이아웃 깨짐 방지
        }
    }

    // 데이터 설정
    func configure(with book: Book) {
        titleLabel.text = book.title
        priceLabel.text = book.price
    }
}
