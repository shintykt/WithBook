//
//  UserEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxSwift

final class User {
    static let shared = User()
    
    private var name = ""
    private var password = ""
    private var books: [Book]? = []
    
    private init() {}
}

// MARK: - アカウント操作

extension User {
        func createAccount(name: String, password: String) {
    //        let id = UUID().uuidString
        }
        
        func deleteAccount() {
            
        }
        
        func signIn(name: String, password: String) {
            self.name = name
            self.password = password
        }
        
        func signOut() {
            
        }
}

// MARK: - ブック操作

extension User {
    func fetchBooks() -> [Book]? {
        return books
    }
    
    func add(_ book: Book) {
        books?.append(book)
    }
    
    func remove(_ book: Book) {
        books?.removeAll(where: { $0.id == book.id })
    }
    
    func replace(_ book: Book) {
        guard let targetIndex = books?.firstIndex(where: { $0.id == book.id }) else { return }
        books?[targetIndex] = book
    }
}

// MARK: - メモ操作

extension User {
    func fetchMemos(about book: Book) -> [Memo]? {
        guard let targetIndex = books?.firstIndex(where: { $0.id == book.id }) else { return book.memos }
        let targetBook = books?[targetIndex]
        return targetBook?.memos
    }
    
    func add(_ memo: Memo, about book: Book) {
        guard let targetIndex = books?.firstIndex(where: { $0.id == book.id }) else { return }
        let targetBook = books?[targetIndex]
        targetBook?.memos?.append(memo)
    }
    
    func remove(_ memo: Memo, about book: Book) {
        guard let targetIndex = books?.firstIndex(where: { $0.id == book.id }) else { return }
        let targetBook = books?[targetIndex]
        targetBook?.memos?.removeAll(where: { $0.id == memo.id })
    }
    
    func replace(_ memo: Memo, about book: Book) {
        guard let targetBookIndex = books?.firstIndex(where: { $0.id == book.id }) else { return }
        let targetBook = books?[targetBookIndex]
        guard let targetMemoIndex = targetBook?.memos?.firstIndex(where: { $0.id == book.id }) else { return }
        targetBook?.memos?[targetMemoIndex] = memo
    }
}
