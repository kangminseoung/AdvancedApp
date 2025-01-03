//
//  ViewController.swift
//  Advanced
//
//  Created by 강민성 on 12/26/24.
//

//
//  ViewController.swift
//  Advanced
//

import UIKit
import SnapKit
import CoreData

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let viewModel = SearchViewModel()
    let customSearchBar = CustomSearchBar()
    private let recentBooksStackView = UIStackView()
    private let recentBooksScrollView = UIScrollView()
    private let collectionView: UICollectionView
    private let searchResultsHeaderLabel = UILabel()
    private let recentBooksLabel = UILabel()
    private let searchTabButton = UIButton()
    private let savedBooksTabButton = UIButton()

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
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .white
        setupSearchBar()
        setupRecentBooks()
        setupSearchResults()
        setupCollectionView()
        setupBottomTabs()
    }

    private func setupSearchBar() {
        view.addSubview(customSearchBar)
        customSearchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        customSearchBar.searchButton.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)
    }

    private func setupRecentBooks() {
        recentBooksLabel.text = "최근 본 책"
        recentBooksLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(recentBooksLabel)
        recentBooksLabel.snp.makeConstraints {
            $0.top.equalTo(customSearchBar.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(16)
        }
        
        
        recentBooksScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(recentBooksScrollView)
        recentBooksScrollView.snp.makeConstraints {
            $0.top.equalTo(recentBooksLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(80)
        }

        recentBooksStackView.axis = .horizontal
        recentBooksStackView.spacing = 16
        recentBooksStackView.isHidden = true
        view.addSubview(recentBooksStackView)
        recentBooksStackView.snp.makeConstraints {
            $0.top.equalTo(recentBooksLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(70)
        }
    }

    private func setupSearchResults() {
        searchResultsHeaderLabel.text = "검색 결과"
        searchResultsHeaderLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(searchResultsHeaderLabel)
        searchResultsHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(recentBooksStackView.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(16)
        }
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "BookCell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchResultsHeaderLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-80)
        }
    }

    private func setupBottomTabs() {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually

        searchTabButton.setTitle("검색 탭", for: .normal)
        searchTabButton.backgroundColor = .lightGray
        searchTabButton.layer.borderWidth = 1
        searchTabButton.layer.borderColor = UIColor.black.cgColor
        searchTabButton.layer.cornerRadius = 8
        searchTabButton.addTarget(self, action: #selector(openSearchTab), for: .touchUpInside)
        buttonStackView.addArrangedSubview(searchTabButton)

        savedBooksTabButton.setTitle("담은 책 리스트 탭", for: .normal)
        savedBooksTabButton.backgroundColor = .lightGray
        savedBooksTabButton.layer.borderWidth = 1
        savedBooksTabButton.layer.borderColor = UIColor.black.cgColor
        savedBooksTabButton.layer.cornerRadius = 8
        savedBooksTabButton.addTarget(self, action: #selector(openSavedBooksTab), for: .touchUpInside)
        buttonStackView.addArrangedSubview(savedBooksTabButton)

        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(50)
        }
    }

    @objc private func openSearchTab() {
        // 검색 화면에서는 아무 작업도 하지 않음
        print("현재 검색 화면입니다.")
    }
    
    @objc private func openSavedBooksTab() {
        // 담은 책 리스트 화면으로 전환
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 1 // 담은 책 화면의 인덱스
        }
    }

    private func bindViewModel() {
        viewModel.onBooksUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }

        viewModel.onRecentBooksUpdated = { [weak self] in
            self?.updateRecentBooks()
        }
    }

    @objc private func handleSearch() {
        guard let query = customSearchBar.searchTextField.text, !query.isEmpty else {
            print("검색어를 입력하세요.")
            return
        }
        
        // 포커스 해제
        customSearchBar.searchTextField.resignFirstResponder()
        
        // 검색 동작 실행
        viewModel.searchBooks(query: query)
    }

    private func updateRecentBooks() {
        recentBooksStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // 기존 뷰 제거

        for book in viewModel.recentBooks {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 35 // 반지름 설정
            imageView.clipsToBounds = true
            imageView.layer.borderColor = UIColor.gray.cgColor // 경계선 설정(옵션)
            imageView.layer.borderWidth = 1.0

            // 이미지 로드
            if let url = URL(string: book.thumbnailURL ?? "") {
                loadImage(from: url) { [weak imageView] image in
                    imageView?.image = image
                }
            } else {
                imageView.image = UIImage(named: "placeholder")
            }

            // CircleView
            let circleView = UIView()
            circleView.layer.cornerRadius = 35
            circleView.clipsToBounds = true
            circleView.addSubview(imageView)

            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview() // CircleView와 동일 크기
            }

            circleView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCircleTap(_:)))
            circleView.addGestureRecognizer(tapGesture)

            recentBooksStackView.addArrangedSubview(circleView)
        }

        recentBooksStackView.isHidden = viewModel.recentBooks.isEmpty
    }

    @objc private func handleCircleTap(_ sender: UITapGestureRecognizer) {
        guard let index = recentBooksStackView.arrangedSubviews.firstIndex(of: sender.view!) else { return }
        guard let book = viewModel.recentBook(at: index) else { return }
//        let detailVC = DetailViewController(book: book)
//        present(detailVC, animated: true, completion: nil)
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }.resume()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfBooks()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! SearchCollectionViewCell
        if let book = viewModel.book(at: indexPath.row) {
            cell.configure(with: book)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedBook = viewModel.book(at: indexPath.row) else { return }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "title == %@", selectedBook.title ?? ""),
//            NSPredicate(format: "author == %@", selectedBook.author ?? "")
        ])

        do {
            let fetchedBooks = try context.fetch(fetchRequest)
            if fetchedBooks.isEmpty {
                let detailVC = DetailViewController(kakaoBook: selectedBook)
                detailVC.delegate = self
                present(detailVC, animated: true, completion: nil)
            } else {
                // 이미 DetailViewController가 표시된 상태에서 알림이 뜨지 않도록 조정
                if presentedViewController == nil {
                    let alert = UIAlertController(title: "알림", message: "\(selectedBook.title ?? "") 책은 이미 담겨 있습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }
        } catch {
            print("Error fetching book: \(error)")
        }
  }
    
    // 새로운 `createCompositionalLayout` 메서드 추가
    static func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 60) // 셀 크기 설정
        layout.minimumLineSpacing = 16 // 셀 간 간격 설정
        return layout
    }
}

extension SearchViewController: DetailViewControllerDelegate {
    func didSaveBook(_ book: Book) {
        viewModel.addRecentBook(book)
        let alert = UIAlertController(title: "알림", message: "\(book.title ?? "") 책 담기 완료!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
