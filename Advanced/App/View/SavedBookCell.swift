//
//  SavedBookCell.swift
//  Advanced
//
//  Created by 강민성 on 1/2/25.
//

import UIKit
import SnapKit

class SavedBookCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }

        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = .gray
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    func configure(with book: Book) {
        titleLabel.text = book.title
        priceLabel.text = "₩\(book.price ?? "0")"
    }
}
