//
//  Book.swift
//  Advanced
//
//  Created by 강민성 on 12/31/24.
//

struct BookResponse: Codable {
    let documents: [KakaoBook]
}

struct KakaoBook: Codable {
    let title: String
    let authors: [String]
    let price: String
    let thumbnail: String
    let contents: String
    
    enum CodingKeys: String, CodingKey {
        case title, authors, price, thumbnail, contents
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        authors = try container.decode([String].self, forKey: .authors)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        contents = try container.decode(String.self, forKey: .contents)
        
        // price를 숫자 또는 문자열로 처리
        if let intPrice = try? container.decode(Int.self, forKey: .price) {
            price = "\(intPrice)"
        } else if let stringPrice = try? container.decode(String.self, forKey: .price) {
            price = stringPrice
        } else {
            price = "0" // 기본값 설정
        }
    }

}
