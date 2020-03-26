//
//  UserEntity.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Firebase
import RxSwift

final class User {
    static let shared = User()
    
    private var name = ""
    private var password = ""
    
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
    func fetchBooks(completion: @escaping ([Book]?) -> Void) {
        booksCollection?.getDocuments(completion: { snapshot, error in
            if let error = error { print(error) }
            completion(snapshot?.documents.map {
                let data = $0.data()
                return Book(
                    id: $0.documentID,
                    title: data["title"] as! String,
                    author: data["author"] as! String
                )
            })
        })
    }
    
    func add(_ book: Book) {
        addFirestore(for: book)
    }
    
    func replace(_ book: Book) {
        replaceFirestore(for: book)
    }
    
    func remove(_ book: Book) {
        booksCollection?.document(book.id).delete { error in
            if let error = error { print(error) }
        }
    }
}

private extension User {
    var booksCollection: CollectionReference? {
        guard let user = Auth.auth().currentUser else { return nil }
        return Firestore.firestore().collection("users").document(user.uid).collection("books")
    }
    
    func addFirestore(for book: Book) {
        updateFirestore(for: book)
    }
    
    func replaceFirestore(for book: Book) {
        updateFirestore(for: book)
    }
    
    func updateFirestore(for book: Book) {
        let docData = [
            "title": book.title,
            "author": book.author
        ]
        booksCollection?.document(book.id).setData(docData) { error in
            if let error = error { print(error) }
        }
    }
}

// MARK: - メモ操作

extension User {
    func fetchMemos(about book: Book, completion: @escaping ([Memo]?) -> Void) {
        memosCollection(for: book)?.getDocuments(completion: { snapshot, error in
            if let error = error { print(error) }
            completion(snapshot?.documents.map {
                let data = $0.data()
                let createTimeStamp = data["create_date"] as! Timestamp
                let updateTimeStamp = data["update_date"] as? Timestamp
                return Memo(
                    id: $0.documentID,
                    createDate: createTimeStamp.dateValue(),
                    updateDate: updateTimeStamp?.dateValue(),
                    title: data["title"] as! String,
                    text: data["text"] as! String
                )
            })
        })
    }
    
    func add(_ memo: Memo, about book: Book) {
        addFirestore(for: memo, about: book)
    }
    
    func replace(_ memo: Memo, about book: Book) {
        replaceFirestore(for: memo, about: book)
    }
    
    func remove(_ memo: Memo, about book: Book) {
        memosCollection(for: book)?.document(memo.id).delete { error in
            if let error = error { print(error) }
        }
    }
}

private extension User {
    func memosCollection(for book: Book) -> CollectionReference? {
        return booksCollection?.document(book.id).collection("memos")
    }
    
    func addFirestore(for memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
        ]
        memosCollection(for: book)?.document(memo.id).setData(docData) { error in
            if let error = error { print(error) }
        }
    }
    
    func replaceFirestore(for memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
            "update_date": Timestamp(date: Date())
        ]
        memosCollection(for: book)?.document(memo.id).setData(docData) { error in
            if let error = error { print(error) }
        }
    }
}
