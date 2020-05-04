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

// TODO: 画像のCRUD
final class MemoRepository {
    private let bookRepository: BookRepository
    
    init(bookRepository: BookRepository = .init()) {
        self.bookRepository = bookRepository
    }
    
    func fetchMemos(about book: Book, completion: @escaping (Memo) -> Void) {
        memosCollection(about: book)?.getDocuments { snapshot, error in
            self.outputIfNeeded(error)
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
                
                self.memoImagesStorage(about: book)?.child(memo.imageName).getData(maxSize: Const.maxImageSize) { data, error in
                    self.outputIfNeeded(error)
                    guard let data = data else { return }
                    memo.imageData = data
                    completion(memo)
                }
            }
        }
    }
    
    func add(_ memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
        ]
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            self.outputIfNeeded(error)
        }
        
        memoImagesStorage(about: book)?.child(memo.imageName).putData(memo.imageData, metadata: nil) { _, error in
            self.outputIfNeeded(error)
        }
    }
    
    func replace(_ memo: Memo, about book: Book) {
        let docData: [String: Any] = [
            "title": memo.title,
            "text": memo.text,
            "create_date": Timestamp(date: memo.createDate),
            "update_date": Timestamp(date: Date())
        ]
        memosCollection(about: book)?.document(memo.id).setData(docData) { error in
            self.outputIfNeeded(error)
        }
        
        memoImagesStorage(about: book)?.child(memo.imageName).putData(memo.imageData, metadata: nil) { _, error in
            self.outputIfNeeded(error)
        }
    }
    
    func remove(_ memo: Memo, about book: Book) {
        memosCollection(about: book)?.document(memo.id).delete { error in
            self.outputIfNeeded(error)
        }
        
        memoImagesStorage(about: book)?.child(memo.imageName).delete { error in
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
