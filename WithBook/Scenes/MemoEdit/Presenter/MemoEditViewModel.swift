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
    private let memo: Memo
    
    init(model: MemoEdit, mode: MemoEditMode) {
        self.model = model
        self.mode = mode
        switch mode {
        case .adding: memo = Memo(title: "", text: nil, image: nil, pages: nil)
        case .replacing(let memo): self.memo = memo
        }
    }
}

extension MemoEditViewModel: ViewModel {
    struct Input {
        let title: Driver<String>
        let text: Driver<String?>
        let image: Binder<UIImage?>
        let completionTrigger: Observable<Void>
    }
    
    struct Output {
        let canTapComplete: Driver<Bool>
        let completionStatus: Observable<Event<Void>>
    }
    
    func transform(input: Input) -> Output {
        input.title
            .drive(onNext: { [weak self] title in
                self?.memo.title = title
            })
            .disposed(by: disposeBag)
        
        input.text
            .drive(onNext: { [weak self] text in
                self?.memo.text = text
            })
            .disposed(by: disposeBag)
            
        input.image
            .onNext(memo.image)
        
        let canTapComplete = input.title
            .flatMap { title -> Driver<Bool> in
                return self.model.validate(title)
            }
        
        let completionStatus = input.completionTrigger
            .flatMap { _ -> Observable<Event<Void>> in
                switch self.mode {
                case .adding: return self.model.add(self.memo).materialize()
                case .replacing: return self.model.replace(self.memo).materialize()
                }
            }
        
        return Output(
            canTapComplete: canTapComplete,
            completionStatus: completionStatus
        )
    }
}
