//
//  SearchViewModel.swift
//  Advanced
//
//  Created by 강민성 on 12/30/24.
//

import Foundation
import CoreData
import UIKit

class SearchViewModel {
    
    private var books: [KakaoBook] = [] // 검색 결과
    private(set) var recentBooks: [Book] = [] // 최근 본 책
    var onBooksUpdated: (() -> Void)? // 검색 결과 업데이트 콜백
    var onRecentBooksUpdated: (() -> Void)? // 최근 본 책 업데이트 콜백
    private var lastSearchQuery: String? // 마지막 검색어 저장

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // API 호출
    func searchBooks(query: String) {
        if lastSearchQuery != query {
            clearExistingBooks() // 검색어가 변경된 경우만 초기화
        }
        
        lastSearchQuery = query // 현재 검색어 저장

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            print("URL 생성 실패: \(urlString)")
            return
        }

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String else {
            print("Kakao API 키를 가져올 수 없습니다.")
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("API 호출 실패: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("API 응답 데이터가 없습니다.")
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(BookResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.books = decodedData.documents
                    self?.onBooksUpdated?()
                }

            } catch {
                print("데이터 디코딩 실패: \(error)")
            }
        }.resume()
    }

    // Core Data 저장
    private func saveBooksToCoreData(_ books: [KakaoBook]) {
        for book in books {
            // 중복 확인
            let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "title == %@", book.title),
                NSPredicate(format: "author == %@", book.authors.first ?? "")
            ])

            do {
                let existingBooks = try context.fetch(fetchRequest)
                if existingBooks.isEmpty {
                    let newBook = Book(context: context)
                    newBook.title = book.title
                    newBook.author = book.authors.first ?? "Unknown"
                    newBook.price = book.price
                    newBook.thumbnailURL = book.thumbnail
                    newBook.contents = book.contents
                }
            } catch {
                print("중복 확인 중 오류 발생: \(error)")
            }
        }

        do {
            try context.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }

    // Core Data에서 데이터 삭제
    private func clearExistingBooks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Book.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            context.reset()
            try context.save()
        } catch {
            print("Error clearing Core Data: \(error)")
        }
    }

    // Core Data에서 검색 결과 가져오기
    func fetchBooksFromCoreData() {
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        do {
            recentBooks = try context.fetch(request)
            onBooksUpdated?()
            print(books)
        } catch {
            print("Error fetching from Core Data: \(error)")
        }
    }

    // 최근 본 책
    func addRecentBook(_ book: Book) {
        if !recentBooks.contains(where: { $0.title == book.title }) {
            recentBooks.insert(book, at: 0)
            if recentBooks.count > 10 {
                recentBooks.removeLast()
            }
            onRecentBooksUpdated?()
        }
    }

    func numberOfBooks() -> Int {
        return books.count
    }

    func book(at index: Int) -> KakaoBook? {
        guard index >= 0 && index < books.count else { return nil }
        return books[index]
    }

    func numberOfRecentBooks() -> Int {
        return recentBooks.count
    }

    func recentBook(at index: Int) -> Book? {
        guard index >= 0 && index < recentBooks.count else { return nil }
        return recentBooks[index]
    }
}

