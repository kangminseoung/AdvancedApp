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
    private let thumbnailImageView = UIImageView()

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

        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(thumbnailImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
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

    func configure(with book: KakaoBook) {
        titleLabel.text = book.title
        priceLabel.text = "₩\(book.price)"
        if let url = URL(string: book.thumbnail) {
            loadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.thumbnailImageView.image = image
                }
            }
        }
    }

    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return completion(nil) }
            completion(UIImage(data: data))
        }.resume()
    }
}
