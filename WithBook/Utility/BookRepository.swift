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
import RxFirebase
import RxSwift

// TODO: 画像CRUD
final class BookRepository {
    func listenBooks() -> Observable<[Book]> {
        return booksCollection()?.rx.listen()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { snapshot -> [Book] in
                return snapshot.documents.map {
                    return Book(
                        id: $0.documentID,
                        title: $0.data()["title"] as! String,
                        author: $0.data()["author"] as! String
                    )
                }
        } ?? .empty()
    }
    
    func add(_ book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let docData = [
                "title": book.title,
                "author": book.author
            ]
            
            self?.booksCollection()?.document(book.id).setData(docData) { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func replace(_ book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let docData = [
                "title": book.title,
                "author": book.author
            ]
            
            self?.booksCollection()?.document(book.id).setData(docData) { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func remove(_ book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            self?.booksCollection()?.document(book.id).delete { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func booksCollection() -> CollectionReference? {
        guard let user = Auth.auth().currentUser else { return nil }
        return Firestore.firestore().collection("users").document(user.uid).collection("books")
    }
    
    func bookImagesStorage() -> StorageReference? {
        guard let user = Auth.auth().currentUser else { return nil }
        guard let url = storageULR else { return nil }
        let storage = Storage.storage().reference(forURL: url)
        return storage.child("users").child(user.uid).child("bookImages")
    }
}

private extension BookRepository {
    var storageULR: String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else { return nil }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any] else { return nil }
        guard let bucket = dictionary["STORAGE_BUCKET"] as? String else { return nil }
        return "gs://" + bucket
    }
}
