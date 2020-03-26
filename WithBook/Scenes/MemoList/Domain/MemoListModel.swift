//
//  MemoListModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/08.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import Foundation

protocol MemoList {
    func fetchMemos(completion: @escaping ([Memo]) -> Void)
    func remove(_ memo: Memo)
}

struct MemoListModel: MemoList {
    private let user: User = .shared
    let book: Book
    
    func fetchMemos(completion: @escaping ([Memo]) -> Void) {
        user.fetchMemos(about: book) { memos in
            completion(memos)
        }
    }
    
    func remove(_ memo: Memo) {
        user.remove(memo, about: book)
    }
}
