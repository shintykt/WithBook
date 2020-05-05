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
    private let model: MemoEdit
    private let disposeBag = DisposeBag()
    
    private var memo: Memo!
    
    init(model: MemoEdit) {
        self.model = model
    }
}

extension MemoEditViewModel: ViewModel {
    struct Input {
        let book: Driver<Book>
        let mode: Driver<MemoEditMode>
        let title: Driver<String>
        let text: Driver<String?>
        let image: Driver<UIImage>
        let completeTap: Driver<Void>
    }
    
    struct Output {
        let memo: Driver<Memo>
        let canTapComplete: Driver<Bool>
        let completeResult: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        input.title
            .drive(onNext: { [weak self] title in
                guard let memo = self?.memo else { return }
                memo.title = title
            })
            .disposed(by: disposeBag)
        
        input.text
            .drive(onNext: { [weak self] text in
                guard let memo = self?.memo else { return }
                memo.text = text ?? Const.defaultText
            })
            .disposed(by: disposeBag)
        
        input.image
            .drive(onNext: { [weak self] image in
                guard let memo = self?.memo else { return }
                memo.image = image
            })
            .disposed(by: disposeBag)
        
        let memo = input.mode
            .map { [weak self] mode -> Memo in
                guard let self = self else { return Memo() }
                
                switch mode {
                case .adding:
                    self.memo = Memo()
                case .replacing(let memo):
                    self.memo = memo
                }
                
                return self.memo
            }
        
        let canTapComplete = input.title
            .flatMap {  [weak self] title -> Driver<Bool> in
                guard let self = self else { return .just(false) }
                return self.model.validate(title)
                    .asDriver(onErrorJustReturn: false)
            }

        let completeResult = Driver.combineLatest(input.book, input.mode, input.completeTap)
            .flatMap { [weak self] book, mode, _ -> Driver<Void> in
                guard let self = self else { return .empty() }
                
                switch mode {
                case .adding:
                    return self.model.add(self.memo, about: book)
                        .asDriver(onErrorDriveWith: .empty())
                case .replacing:
                    return self.model.replace(self.memo, about: book)
                        .asDriver(onErrorDriveWith: .empty())
                }
            }
        
        return Output(
            memo: memo,
            canTapComplete: canTapComplete,
            completeResult: completeResult
        )
    }
}
