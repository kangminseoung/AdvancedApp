//
//  CustomSearchBar.swift
//  Advanced
//
//  Created by 강민성 on 12/31/24.
//

import UIKit
import SnapKit

class CustomSearchBar: UIView {

    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    private let underlineView = UIView()



    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupUI() {

        backgroundColor = .white
        layer.cornerRadius = 25
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor


        searchTextField.placeholder = "sayno"
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        searchTextField.borderStyle = .none
        addSubview(searchTextField)
        
        searchTextField.snp.makeConstraints {
            $0.left.equalToSuperview().offset(25)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }


        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .gray
        addSubview(searchButton)
        
        searchButton.snp.makeConstraints {
            $0.left.equalTo(searchTextField.snp.right).offset(8)
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(24)
        }
        
        underlineView.backgroundColor = UIColor.gray
        underlineView.layer.borderWidth = 2
        addSubview(underlineView)
        
        underlineView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(1)
        }


        searchTextField.snp.makeConstraints {
            $0.right.equalTo(searchButton.snp.left).offset(-8)
        }
    }
}
