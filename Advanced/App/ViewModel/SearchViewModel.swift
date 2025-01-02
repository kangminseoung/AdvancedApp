//
//  SearchViewModel.swift
//  Advanced
//
//  Created by 강민성 on 12/30/24.
//

import Foundation

class SearchViewModel {
    
    private(set) var books: [Book] = [] // 검색 결과
    private(set) var recentBooks: [Book] = [] // 최근 본 책
    var onBooksUpdated: (() -> Void)?
    
    func fetchBooks(query: String) {
        // Mock Data
        books = [
            Book(title: "세이노의 가르침", price: "14,000원"),
            Book(title: "달러구트 꿈 백화점", price: "12,000원"),
            Book(title: "아몬드", price: "13,500원")
        ]
        onBooksUpdated?()
    }

    func numberOfSections() -> Int {
        return recentBooks.isEmpty ? 1 : 2
    }

    func numberOfItems(in section: Int) -> Int {
        if section == 0 && !recentBooks.isEmpty {
            return recentBooks.count
        }
        return books.count
    }

    func book(at indexPath: IndexPath) -> Book {
        if indexPath.section == 0 && !recentBooks.isEmpty {
            return recentBooks[indexPath.row]
        }
        return books[indexPath.row]
    }

    func addRecentBook(_ book: Book) {
        if !recentBooks.contains(where: { $0.title == book.title }) {
            recentBooks.insert(book, at: 0)
            if recentBooks.count > 10 { recentBooks.removeLast() }
            onBooksUpdated?()
        }
    }
}
