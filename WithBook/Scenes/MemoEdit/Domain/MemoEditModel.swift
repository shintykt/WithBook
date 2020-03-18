//
//  MemoEditModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/14.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

protocol MemoEdit {
    func validate(_ title: String?) -> Driver<Bool>
    func add(_ memo: Memo) -> Observable<Void>
    func replace(_ memo: Memo) -> Observable<Void>
}

struct MemoEditModel: MemoEdit {
    let book: Book
    
    func validate(_ title: String?) -> Driver<Bool> {
        guard let title = title else { return .just(false) }
        return .just(!title.isEmpty)
    }
    
    func add(_ memo: Memo) -> Observable<Void> {
        User.shared.add(memo, about: book)
        return .just(())
    }
    
    func replace(_ memo: Memo) -> Observable<Void> {
        User.shared.replace(memo, about: book)
        return .just(())
    }
}
