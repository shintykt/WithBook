//
//  MemoRepository.swift
//  WithBook-Development
//
//  Created by shintykt on 2020/05/04.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage
import RxFirebase
import RxSwift

final class MemoRepository {
    private let bookRepository: BookRepository
    
    init(bookRepository: BookRepository = .init()) {
        self.bookRepository = bookRepository
    }
    
    func listenMemos(about book: Book) -> Observable<[Memo]> {
        return memosCollection(about: book)?
            .order(by: "createdTime", descending: false)
            .rx
            .listen()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { snapshot -> [Memo] in
                return snapshot.documents
                    .map { try? MemoEntity(from: $0) }
                    .compactMap { $0 }
                    .map {
                        return Memo(
                            id: $0.documentId,
                            createdTime: $0.createdTime.dateValue(),
                            updatedTime: $0.updatedTime?.dateValue(),
                            title: $0.title,
                            text: $0.text,
                            image: nil
                        )
                    }
            } ?? .empty()
    }
    
    func add(_ memo: Memo, about book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let docData: [String: Any] = [
                "createdTime": Timestamp(date: memo.createdTime),
                "updatedTime": NSNull(),
                "title": memo.title,
                "text": memo.text ?? NSNull(),
                "imageURL": NSNull()
            ]
            
            // TODO: "imageURL"処理
            self?.memosCollection(about: book)?.document(memo.id).setData(docData) { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func replace(_ memo: Memo, about book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let docData: [String: Any] = [
                "createdTime": Timestamp(date: memo.createdTime),
                "updatedTime": Timestamp(date: Date()),
                "title": memo.title,
                "text": memo.text ?? NSNull(),
                "imageURL": NSNull()
            ]
            
            // TODO: "imageURL"処理
            self?.memosCollection(about: book)?.document(memo.id).setData(docData) { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func remove(_ memo: Memo, about book: Book) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            // TODO: "imageURL"処理
            self?.memosCollection(about: book)?.document(memo.id).delete { error in
                if let error = error { observer.onError(error); return }
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

private extension MemoRepository {
    func memosCollection(about book: Book) -> CollectionReference? {
        return bookRepository.booksCollection()?.document(book.id).collection("memos")
    }
    
    func memoImagesStorage(about book: Book) -> StorageReference? {
        return bookRepository.bookImagesStorage()?.child(book.id).child("memoImages")
    }
}
