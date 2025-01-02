//
//  ViewController.swift
//  Advanced
//
//  Created by 강민성 on 12/26/24.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let viewModel = SearchViewModel()
    private let customSearchBar = CustomSearchBar()
    private let recentBooksStackView = UIStackView()
    private let collectionView: UICollectionView
    
    init() {
        let layout = SearchViewController.createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Custom SearchBar
        view.addSubview(customSearchBar)
        customSearchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        // "최근 본 책" 타이틀
        let titleLabel = UILabel()
        titleLabel.text = "최근 본 책"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(customSearchBar.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(16)
        }

        // RecentBooks StackView
        recentBooksStackView.axis = .horizontal
        recentBooksStackView.distribution = .fillEqually
        recentBooksStackView.spacing = 16
        view.addSubview(recentBooksStackView)
        recentBooksStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(32)
            $0.height.equalTo(70) // 크기 조정
        }

        // Add Recent Book Circles
        for _ in 0..<4 {
            let circleView = UIView()
            circleView.backgroundColor = .red
            circleView.layer.cornerRadius = 35 // 크기 조정 (80 / 2)
            circleView.layer.borderColor = UIColor.black.cgColor
            circleView.layer.borderWidth = 1
            recentBooksStackView.addArrangedSubview(circleView)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCircleTap))
            circleView.addGestureRecognizer(tapGesture)
            circleView.isUserInteractionEnabled = true
        }

        // 밑줄
        let underlineView = UIView()
        underlineView.backgroundColor = .lightGray
        view.addSubview(underlineView)
        underlineView.snp.makeConstraints {
            $0.top.equalTo(recentBooksStackView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        // "검색 결과" 타이틀
        let searchResultsTitleLabel = UILabel()
        searchResultsTitleLabel.text = "검색 결과"
        searchResultsTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(searchResultsTitleLabel)
        searchResultsTitleLabel.snp.makeConstraints {
            $0.top.equalTo(underlineView.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(16)
        }

        // CollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "BookCell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchResultsTitleLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-80)
        }

        // 하단 버튼
        let searchTabButton = UIButton()
        searchTabButton.backgroundColor = .gray
        searchTabButton.setTitle("검색 탭", for: .normal)
        searchTabButton.setTitleColor(.black, for: .normal)
        searchTabButton.layer.borderWidth = 1
        searchTabButton.layer.borderColor = UIColor.black.cgColor
        view.addSubview(searchTabButton)
        searchTabButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(50)
            $0.right.equalTo(view.snp.centerX).offset(-8) // 버튼 간 간격
        }

        let savedBooksTabButton = UIButton()
        savedBooksTabButton.backgroundColor = .gray
        savedBooksTabButton.setTitle("담은 책 리스트 탭", for: .normal)
        savedBooksTabButton.setTitleColor(.black, for: .normal)
        savedBooksTabButton.layer.borderWidth = 1
        savedBooksTabButton.layer.borderColor = UIColor.black.cgColor
        savedBooksTabButton.addTarget(self, action: #selector(goToSavedBooks), for: .touchUpInside)
        view.addSubview(savedBooksTabButton)
        savedBooksTabButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(50)
            $0.left.equalTo(view.snp.centerX).offset(8) // 버튼 간 간격
        }
    }

    static func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 60) // 높이 조정
        layout.minimumLineSpacing = 12 // 간격 조정
        return layout
    }

    @objc private func handleCircleTap() {
        let detailVC = DetailViewController(book: Book(title: "Sample", price: "10,000원"))
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true, completion: nil)
    }

    @objc private func goToSavedBooks() {
        let savedBooksVC = SavedBooksViewController()
        navigationController?.pushViewController(savedBooksVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! SearchCollectionViewCell
        cell.configure(with: Book(title: "Sample \(indexPath.row + 1)", price: "\(indexPath.row * 1000)원"))
        return cell
    }
}
