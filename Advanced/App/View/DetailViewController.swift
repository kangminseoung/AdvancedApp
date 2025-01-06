//
//  DetailViewController.swift
//  Advanced
//
//  Created by 강민성 on 12/31/24.
//


import UIKit
import SnapKit
import CoreData

protocol DetailViewControllerDelegate: AnyObject {
    
    func didSaveBook(_ book: Book)
}

class DetailViewController: UIViewController {
    
    private let kakaoBook: KakaoBook
    weak var delegate: DetailViewControllerDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    init(kakaoBook: KakaoBook) {
        self.kakaoBook = kakaoBook
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // ScrollView & ContentView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // Thumbnail ImageView
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.clipsToBounds = true
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        // Price Label
        let priceLabel = UILabel()
        priceLabel.font = UIFont.boldSystemFont(ofSize: 18)
        priceLabel.textAlignment = .center
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // Floating Button Stack View
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.distribution = .fillProportionally
        view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }
        
        // Close Button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("X", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.addTarget(self, action: #selector(closeDetail), for: .touchUpInside)
        buttonStackView.addArrangedSubview(closeButton)
        
        // Save Button
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("담기", for: .normal)
        saveButton.backgroundColor = .green
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveBook), for: .touchUpInside)
        buttonStackView.addArrangedSubview(saveButton)
        
        self.titleLabel = titleLabel
        self.thumbnailImageView = thumbnailImageView
        self.priceLabel = priceLabel
        self.descriptionLabel = descriptionLabel
    }
    
    private var titleLabel: UILabel!
    private var thumbnailImageView: UIImageView!
    private var priceLabel: UILabel!
    private var descriptionLabel: UILabel!
    
    private func configure() {
        
        titleLabel.text = kakaoBook.title
        priceLabel.text = "₩\(kakaoBook.price)"
        descriptionLabel.text = kakaoBook.contents
        
        if let url = URL(string: kakaoBook.thumbnail) {
            loadImage(from: url) { [weak self] image in
                self?.thumbnailImageView.image = image
            }
        } else {
            thumbnailImageView.image = UIImage(named: "placeholder")
        }
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
    
    @objc private func closeDetail() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveBook() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "title == %@", kakaoBook.title),
            NSPredicate(format: "author == %@", kakaoBook.authors.first ?? "")
        ])
        
        do {
            let existingBooks = try context.fetch(fetchRequest)
            
            if existingBooks.isEmpty {
                let savedBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context) as! Book
                savedBook.title = kakaoBook.title
                savedBook.author = kakaoBook.authors.first ?? "Unknown"
                savedBook.price = kakaoBook.price
                savedBook.thumbnailURL = kakaoBook.thumbnail
                savedBook.contents = kakaoBook.contents
                
                try context.save()
                print("책 저장 완료: \(kakaoBook.title)")
                
                delegate?.didSaveBook(savedBook)
                dismiss(animated: true) // DetailViewController 닫기
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert(message: "\(self.kakaoBook.title) 책은 이미 담겨 있습니다.")
                }
            }
        } catch {
            print("책 저장 실패: \(error)")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        // 탭바 컨트롤러나 루트 뷰 컨트롤러에서 Alert 표시
        if let tabBarController = presentingViewController as? UITabBarController {
            tabBarController.present(alert, animated: true, completion: nil)
        } else {
            presentingViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
