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
    
    func fetchMemos(about book: Book, completion: @escaping (Memo) -> Void) {
        memosCollection(about: book)?.getDocuments { snapshot, error in
            self.outputIfNeeded(error)
            snapshot?.documents
                .map { document -> MemoEntity? in
                    return try? MemoEntity(from: document)
                }
                .compactMap { $0 }
                .forEach {
                    let memo = Memo(
                        id: $0.documentId,
                        createdTime: $0.createdTime.dateValue(),
                        updatedTime: $0.updatedTime?.dateValue(),
                        title: $0.title,
                        text: $0.text,
                        image: nil
                    )
                    completion(memo)
                }
        }
    }
    
    func add(_ memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "createdTime": Timestamp(date: memo.createdTime),
            "updatedTime": NSNull(),
            "title": memo.title,
            "text": memo.text ?? NSNull(),
            "imageURL": NSNull()
        ]
            
        // TODO: "imageURL"処理
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            self.outputIfNeeded(error)
        }
    }
    
    func replace(_ memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "createdTime": Timestamp(date: memo.createdTime),
            "updatedTime": Timestamp(date: Date()),
            "title": memo.title,
            "text": memo.text ?? NSNull(),
            "imageURL": NSNull()
        ]
        
        // TODO: "imageURL"処理
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            self.outputIfNeeded(error)
        }
    }
    
    func remove(_ memo: Memo, about book: Book) {
        memosCollection(about: book)?.document(memo.id).delete { error in
            self.outputIfNeeded(error)
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
    
    func outputIfNeeded(_ error: Error?) {
        guard let error = error else { return }
        print(error)
    }
}
