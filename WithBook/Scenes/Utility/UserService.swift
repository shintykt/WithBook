//
//  UserService.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Firebase
import RxSwift

final class User {
    static let shared = User()
    private let repository: ContentsRepository = .shared
    
    private init() {}
}

// MARK: - ブック操作

extension User {
    func fetchBooks(completion: @escaping ([Book]) -> Void) {
        repository.fetchFirestore { books in
            guard let books = books else { return }
            completion(books)
        }
    }
    
    func add(_ book: Book) {
        repository.addFirestore(for: book)
    }
    
    func replace(_ book: Book) {
        repository.replaceFirestore(for: book)
    }
    
    func remove(_ book: Book) {
        repository.removeFirestore(for: book)
    }
}

// MARK: - メモ操作

extension User {
    func fetchMemos(about book: Book, completion: @escaping ([Memo]) -> Void) {
        repository.fetchFirestore(about: book) { memos in
            guard let memos = memos else { return }
            completion(memos)
        }
    }
    
    func add(_ memo: Memo, about book: Book) {
        repository.addFirestore(for: memo, about: book)
    }
    
    func replace(_ memo: Memo, about book: Book) {
        repository.replaceFirestore(for: memo, about: book)
    }
    
    func remove(_ memo: Memo, about book: Book) {
        repository.removeFirestore(for: memo, about: book)
    }
}
