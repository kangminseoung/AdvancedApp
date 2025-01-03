//
//  SavedBooksViewController.swift
//  Advanced
//
//  Created by 강민성 on 12/31/24.
//

//
//  SavedBooksViewController.swift
//  Advanced
//
//  Created by 강민성 on 12/31/24.


import UIKit
import CoreData
import SnapKit

class SavedBooksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let collectionView: UICollectionView
    private let addButton = UIButton()
    private let clearButton = UIButton()
    private let searchTabButton = UIButton()
    private let savedBooksTabButton = UIButton()
    private var savedBooks = [Book]() // 저장된 책 데이터

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 60)
        layout.minimumLineSpacing = 16
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSavedBooks()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedBooks() // 최신 데이터 로드
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "담은 책"

        // "추가" 버튼
        addButton.setTitle("추가", for: .normal)
        addButton.setTitleColor(.green, for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addButton.addTarget(self, action: #selector(addBook), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }

        // "전체 삭제" 버튼
        clearButton.setTitle("전체 삭제", for: .normal)
        clearButton.setTitleColor(.red, for: .normal)
        clearButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        clearButton.addTarget(self, action: #selector(clearBooks), for: .touchUpInside)
        view.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(addButton)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(40)
            make.width.equalTo(100)
        }

        // 컬렉션 뷰 설정
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SavedBookCell.self, forCellWithReuseIdentifier: "SavedBookCell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-80) // 하단 탭 버튼 공간 확보
        }

        setupBottomTabs()
    }

    private func setupBottomTabs() {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillEqually

        // 검색 탭 버튼
        searchTabButton.setTitle("검색 탭", for: .normal)
        searchTabButton.backgroundColor = .lightGray
        searchTabButton.layer.borderWidth = 1
        searchTabButton.layer.borderColor = UIColor.black.cgColor
        searchTabButton.layer.cornerRadius = 8
        searchTabButton.addTarget(self, action: #selector(openSearchTab), for: .touchUpInside)
        buttonStackView.addArrangedSubview(searchTabButton)

        // 담은 책 리스트 탭 버튼
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
        // 첫 번째 탭(검색 화면)으로 이동
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0
        }
    }

    @objc private func openSavedBooksTab() {
        // 현재 담은 책 리스트 화면에서 아무 작업도 하지 않음
        print("현재 담은 책 리스트 화면입니다.")
    }

    private func fetchSavedBooks() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()

        do {
            savedBooks = try context.fetch(fetchRequest)
            collectionView.reloadData() // UI 업데이트
            print("저장된 책 목록: \(savedBooks.map { $0.title ?? "" })")
        } catch {
            print("책 가져오기 실패: \(error)")
        }
    }

    @objc private func addBook() {
        // 첫 번째 탭(검색 화면)으로 이동하고 서치바 활성화
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0
            if let searchVC = tabBarController.viewControllers?.first as? SearchViewController {
                DispatchQueue.main.async {
                    searchVC.customSearchBar.searchTextField.becomeFirstResponder()
                }
            }
        }
    }

    @objc private func clearBooks() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Book.fetchRequest()
        let deletRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deletRequest)
            context.reset()

            
            savedBooks.removeAll()
            
            // UI 업데이트
            collectionView.reloadData()
            print("모든 책 삭제 완료")

        } catch {
            print("Core Data 초기화 실패: \(error)")
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SavedBookCell", for: indexPath) as! SavedBookCell
        cell.configure(with: savedBooks[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let bookToDelete = self.savedBooks[indexPath.row]
            context.delete(bookToDelete)

            do {
                try context.save()
                self.savedBooks.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [indexPath])
                completionHandler(true)
            } catch {
                print("Failed to delete book: \(error)")
                completionHandler(false)
            }
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SavedBooksViewController: DetailViewControllerDelegate {
    func didSaveBook(_ book: Book) {
        fetchSavedBooks()
        savedBooks.append(book) // 배열에 새 책 추가
        collectionView.reloadData() // UI 갱신
        print("새 책이 추가되었습니다: \(book.title ?? "")")
    }
}
