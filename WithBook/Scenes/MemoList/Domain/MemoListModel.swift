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
    let book: Book
    
    func fetchMemos(completion: @escaping ([Memo]) -> Void) {
        User.shared.fetchMemos(about: book) { memos in
            guard let memos = memos else { return }
            completion(memos)
        }
    }
    
    func remove(_ memo: Memo) {
        User.shared.remove(memo, about: book)
    }
}
