//
//  ContentsRepository.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/03/26.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

struct ContentsRepository {
    static let shared = ContentsRepository()
    private init() {}
}

// MARK: - ブック操作

extension ContentsRepository {
    func fetchFirestore(completion: @escaping ([Book]?) -> Void) {
        booksCollection()?.getDocuments(completion: { snapshot, error in
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
    
    func addFirestore(for book: Book) {
        let docData = [
            "title": book.title,
            "author": book.author
        ]
        booksCollection()?.document(book.id).setData(docData) { error in
            if let error = error { print(error) }
        }
    }
    
    func replaceFirestore(for book: Book) {
        let docData = [
            "title": book.title,
            "author": book.author
        ]
        booksCollection()?.document(book.id).setData(docData) { error in
            if let error = error { print(error) }
        }
    }
    
    func removeFirestore(for book: Book) {
        booksCollection()?.document(book.id).delete { error in
            if let error = error { print(error) }
        }
    }
    
    private func booksCollection() -> CollectionReference? {
        guard let user = Auth.auth().currentUser else { return nil }
        return Firestore.firestore().collection("users").document(user.uid).collection("books")
    }
}

// MARK: - メモ操作

extension ContentsRepository {
    func fetchFirestore(about book: Book, completion: @escaping ([Memo]?) -> Void) {
        memosCollection(about: book)?.getDocuments(completion: { snapshot, error in
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
    
    func removeFirestore(for memo: Memo, about book: Book) {
        memosCollection(about: book)?.document(memo.id).delete { error in
            if let error = error { print(error) }
        }
    }
    
    func addFirestore(for memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
        ]
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
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
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            if let error = error { print(error) }
        }
    }
    
    private func memosCollection(about book: Book) -> CollectionReference? {
        return booksCollection()?.document(book.id).collection("memos")
    }
}
