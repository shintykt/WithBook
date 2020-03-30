//
//  BookListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/23.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol BookList {
    func fetchBooks(completion: @escaping ([BookListSectionModel]) -> Void)
    func add(_ item: BookListSectionItem, completion: @escaping ([BookListSectionModel]) -> Void)
    func replace(_ item: BookListSectionItem, completion: @escaping ([BookListSectionModel]) -> Void)
    func remove(_ item: BookListSectionItem, completion: @escaping ([BookListSectionModel]) -> Void)
}

final class BookListModel {
    private let user: User = .shared
    private var bookItems: [BookListSectionItem] = []
    private var sectionModels: [BookListSectionModel] {
        return [BookListSectionModel(model: .normal, items: bookItems)]
    }
}

extension BookListModel: BookList {
    func fetchBooks(completion: @escaping ([BookListSectionModel]) -> Void) {
        user.fetchBooks { [weak self] book in
            guard let strongSelf = self else { return }
            let item = BookListSectionItem(book: book)
            strongSelf.bookItems.append(item)
            completion(strongSelf.sectionModels)
        }
    }
    
    func add(_ item: BookListSectionItem, completion: @escaping ([BookListSectionModel]) -> Void) {
        user.add(item.book)
        bookItems.append(item)
        completion(sectionModels)
    }
    
    func replace(_ item: BookListSectionItem, completion: @escaping ([BookListSectionModel]) -> Void) {
        user.replace(item.book)
        guard let targetIndex = bookItems.firstIndex(where: { $0.book.id == item.book.id }) else { return }
        bookItems[targetIndex] = item
        completion(sectionModels)
    }
    
    func remove(_ item: BookListSectionItem, completion: @escaping ([BookListSectionModel]) -> Void) {
        user.remove(item.book)
        bookItems.removeAll(where: { $0.book.id == item.book.id })
        completion(sectionModels)
    }
}
