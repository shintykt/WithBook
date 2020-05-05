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

protocol BookCRUD {
    func listenBooks() -> Observable<[Book]>
    func add(_ book: Book) -> Observable<Void>
    func replace(_ book: Book) -> Observable<Void>
    func remove(_ book: Book) -> Observable<Void>
}

protocol BookReference {
    func booksCollection() -> CollectionReference?
    func bookImagesStorage() -> StorageReference?
}

struct BookRepository {
    let authRepository: AuthReference
    
    init(authRepository: AuthReference = AuthRepository()) {
        self.authRepository = authRepository
    }
}

extension BookRepository: BookCRUD {
    // ブックを監視(Firestoreで更新がある度に呼び出し)
    func listenBooks() -> Observable<[Book]> {
        return booksCollection()?
            .order(by: "createdTime", descending: true)
            .rx
            .listen()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { snapshot -> [Book] in
                return snapshot.documents
                    .map { try? BookEntity(from: $0) }
                    .compactMap { $0 }
                    .map {
                        return Book(
                            id: $0.documentId,
                            createdTime: $0.createdTime.dateValue(),
                            updatedTime: $0.updatedTime?.dateValue(),
                            title: $0.title,
                            author: $0.author,
                            image: nil
                        )
                    }
        } ?? .empty()
    }
    
    // ブックを追加
    func add(_ book: Book) -> Observable<Void> {
        return Observable.create { observer in
            let docData: [String: Any] = [
                "createdTime": Timestamp(date: book.createdTime),
                "updatedTime": NSNull(),
                "title": book.title,
                "author": book.author ?? NSNull(),
                "imageURL": NSNull()
            ]
            
            // TODO: "imageURL"処理
            self.booksCollection()?.document(book.id).setData(docData) { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    // ブックを更新
    func replace(_ book: Book) -> Observable<Void> {
        return Observable.create { observer in
            let docData: [String: Any] = [
                "createdTime": Timestamp(date: book.createdTime),
                "updatedTime": Timestamp(date: Date()),
                "title": book.title,
                "author": book.author ?? NSNull(),
                "imageURL": NSNull()
            ]
            
            // TODO: "imageURL"処理
            self.booksCollection()?.document(book.id).setData(docData) { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    // ブックを削除
    func remove(_ book: Book) -> Observable<Void> {
        return Observable.create { observer in
            // TODO: "imageURL"処理
            self.booksCollection()?.document(book.id).delete { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

extension BookRepository: BookReference {
    func booksCollection() -> CollectionReference? {
        guard let userId = authRepository.userId else { return nil }
        return Firestore.firestore().collection("users").document(userId).collection("books")
    }
    
    func bookImagesStorage() -> StorageReference? {
        guard let userId = authRepository.userId, let url = storageULR else { return nil }
        let storage = Storage.storage().reference(forURL: url)
        return storage.child("users").child(userId).child("bookImages")
    }
}

private extension BookRepository {
    var storageULR: String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any],
              let bucket = dictionary["STORAGE_BUCKET"] as? String
        else { return nil }
        return "gs://" + bucket
    }
}
