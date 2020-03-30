//
//  UserService.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

final class User {
    static let shared = User()
    private let repository: ContentsRepository = .shared
    
    private init() {}
}

// MARK: - ブック操作

extension User {
    func fetchBooks(completion: @escaping (Book) -> Void) {
        repository.fetchFirebase { book in
            completion(book)
        }
    }
    
    func add(_ book: Book) {
        repository.addFirebase(for: book)
    }
    
    func replace(_ book: Book) {
        repository.replaceFirebase(for: book)
    }
    
    func remove(_ book: Book) {
        repository.removeFirebase(for: book)
    }
}

// MARK: - メモ操作

extension User {
    func fetchMemos(about book: Book, completion: @escaping (Memo) -> Void) {
        repository.fetchFirebase(about: book) { memo in
            completion(memo)
        }
    }
    
    func add(_ memo: Memo, about book: Book) {
        repository.addFirebase(for: memo, about: book)
    }
    
    func replace(_ memo: Memo, about book: Book) {
        repository.replaceFirebase(for: memo, about: book)
    }
    
    func remove(_ memo: Memo, about book: Book) {
        repository.removeFirebase(for: memo, about: book)
    }
}
