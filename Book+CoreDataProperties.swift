//
//  Book+CoreDataProperties.swift
//  Advanced
//
//  Created by 강민성 on 1/2/25.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var price: String?
    @NSManaged public var thumbnailURL: String?
    @NSManaged public var contents: String?

}

extension Book : Identifiable {

}
