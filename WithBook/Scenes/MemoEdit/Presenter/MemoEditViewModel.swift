//
//  MemoEditViewModel.swift
//  WithBook
//
//  Created by shintykt on 2020/03/14.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift

enum MemoEditMode {
    case adding
    case replacing(Memo)
}

final class MemoEditViewModel {
    private var model: MemoEdit
    private let disposeBag = DisposeBag()
    
    let mode: MemoEditMode
    let memo: Memo
    
    init(model: MemoEdit, mode: MemoEditMode) {
        self.model = model
        self.mode = mode
        switch mode {
        case .adding: memo = Memo()
        case .replacing(let memo): self.memo = memo
        }
    }
}

extension MemoEditViewModel: ViewModel {
    struct Input {
        let title: Driver<String>
        let text: Driver<String?>
    }
    
    struct Output {
        let canTapComplete: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.title
            .drive(onNext: { [weak self] title in
                self?.memo.title = title
            })
            .disposed(by: disposeBag)
        
        input.text
            .drive(onNext: { [weak self] text in
                self?.memo.text = text ?? Const.defaultText
            })
            .disposed(by: disposeBag)
        
        let canTapComplete = input.title
            .flatMap { title -> Driver<Bool> in
                return self.model.validate(title)
            }
        
        return Output(
            canTapComplete: canTapComplete
        )
    }
}

extension MemoEditViewModel {
    func input(_ image: UIImage) {
        memo.image = image
    }
}
