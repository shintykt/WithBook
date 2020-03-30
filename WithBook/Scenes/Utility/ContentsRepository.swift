//
//  ContentsRepository.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/03/26.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

struct ContentsRepository {
    static let shared = ContentsRepository()
    private init() {}
}

// MARK: - ブック操作

extension ContentsRepository {
    // FIXME: 画像取得の最適化(キャッシュ化)
    func fetchFirebase(completion: @escaping (Book) -> Void) {
        booksCollection()?.getDocuments { snapshot, error in
            if let error = error { print(error) }
            
            snapshot?.documents.forEach {
                let data = $0.data()
                let book = Book(
                    id: $0.documentID,
                    title: data["title"] as! String,
                    author: data["author"] as! String
                )
                
                self.bookImagesStorage()?.child(book.imageName).getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error { print(error) }
                    guard let data = data else { return }
                    book.imageData = data
                    completion(book)
                }
            }
        }
    }
    
    func addFirebase(for book: Book) {
        let docData = [
            "title": book.title,
            "author": book.author
        ]
        booksCollection()?.document(book.id).setData(docData) { error in
            if let error = error { print(error) }
        }
        
        bookImagesStorage()?.child(book.imageName).putData(book.imageData, metadata: nil) { _, error in
            if let error = error { print(error) }
        }
    }
    
    func replaceFirebase(for book: Book) {
        let docData = [
            "title": book.title,
            "author": book.author
        ]
        booksCollection()?.document(book.id).setData(docData) { error in
            if let error = error { print(error) }
        }
        
        bookImagesStorage()?.child(book.imageName).putData(book.imageData, metadata: nil) { _, error in
            if let error = error { print(error) }
        }
    }
    
    func removeFirebase(for book: Book) {
        booksCollection()?.document(book.id).delete { error in
            if let error = error { print(error) }
        }
        
        bookImagesStorage()?.child(book.imageName).delete { error in
            if let error = error { print(error) }
        }
    }
    
    private func booksCollection() -> CollectionReference? {
        guard let user = Auth.auth().currentUser else { return nil }
        return Firestore.firestore().collection("users").document(user.uid).collection("books")
    }
    
    private func bookImagesStorage() -> StorageReference? {
        guard let user = Auth.auth().currentUser else { return nil }
        guard let url = strageULR else { return nil }
        let storage = Storage.storage().reference(forURL: url)
        return storage.child("users").child(user.uid).child("bookImages")
    }
    
    private var strageULR: String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else { return nil }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any] else { return nil }
        guard let bucket = dictionary["STORAGE_BUCKET"] as? String else { return nil }
        return "gs://" + bucket
    }
}

// MARK: - メモ操作

extension ContentsRepository {
    // FIXME: 画像取得の最適化(キャッシュ化)
    func fetchFirebase(about book: Book, completion: @escaping (Memo) -> Void) {
        memosCollection(about: book)?.getDocuments { snapshot, error in
            if let error = error { print(error) }
            snapshot?.documents.forEach {
                let data = $0.data()
                let createTimeStamp = data["create_date"] as! Timestamp
                let updateTimeStamp = data["update_date"] as? Timestamp
                let memo = Memo(
                    id: $0.documentID,
                    createDate: createTimeStamp.dateValue(),
                    updateDate: updateTimeStamp?.dateValue(),
                    title: data["title"] as! String,
                    text: data["text"] as! String
                )
                
                self.memoImagesStorage(about: book)?.child(memo.imageName).getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error { print(error) }
                    guard let data = data else { return }
                    memo.imageData = data
                    completion(memo)
                }
            }
        }
    }
    
    func addFirebase(for memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
        ]
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            if let error = error { print(error) }
        }
        
        memoImagesStorage(about: book)?.child(memo.imageName).putData(memo.imageData, metadata: nil) { _, error in
            if let error = error { print(error) }
        }
    }
    
    func replaceFirebase(for memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
            "update_date": Timestamp(date: Date())
        ]
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            if let error = error { print(error) }
        }
        
        memoImagesStorage(about: book)?.child(memo.imageName).putData(memo.imageData, metadata: nil) { _, error in
            if let error = error { print(error) }
        }
    }
    
    func removeFirebase(for memo: Memo, about book: Book) {
        memosCollection(about: book)?.document(memo.id).delete { error in
            if let error = error { print(error) }
        }
        
        memoImagesStorage(about: book)?.child(memo.imageName).delete { error in
            if let error = error { print(error) }
        }
    }
    
    private func memosCollection(about book: Book) -> CollectionReference? {
        return booksCollection()?.document(book.id).collection("memos")
    }
    
    private func memoImagesStorage(about book: Book) -> StorageReference? {
        return bookImagesStorage()?.child(book.id).child("memoImages")
    }
}
