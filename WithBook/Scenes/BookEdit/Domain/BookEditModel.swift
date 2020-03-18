//
//  BookEditModel.swift
//  WithBook
//
//  Created by shintykt on 2020/02/25.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

protocol BookEdit {
    func validate(_ title: String?) -> Driver<Bool>
    func add(_ book: Book) -> Observable<Void>
    func replace(_ book: Book) -> Observable<Void>
}

struct BookEditModel: BookEdit {
    func validate(_ title: String?) -> Driver<Bool> {
        guard let title = title else { return .just(false) }
        return .just(!title.isEmpty)
    }
    
    func add(_ book: Book) -> Observable<Void> {
        User.shared.add(book)
        return .just(())
    }
    
    func replace(_ book: Book) -> Observable<Void> {
        User.shared.replace(book)
        return .just(())
    }
}
