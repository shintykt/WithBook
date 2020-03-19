//
//  MemoEditViewController.swift
//  WithBook
//
//  Created by shintykt on 2020/03/02.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

struct MemoEditViewControllerFactory {
    private init() {}
    static func create(for book: Book, _ mode: MemoEditMode) -> MemoEditViewController {
        let viewController = R.storyboard.memoEditViewController().instantiateInitialViewController() as! MemoEditViewController
        viewController.inject(book: book, mode: mode)
        return viewController
    }
}

final class MemoEditViewController: UIViewController {
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var selectImageButton: UIButton!
    @IBOutlet private weak var completeButton: UIButton!
    
    private var viewModel: MemoEditViewModel!
    private let disposeBag = DisposeBag()
    
    weak var delegate: PresentedControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
    
    fileprivate func inject(book: Book, mode: MemoEditMode) {
        let model = MemoEditModel(book: book)
        viewModel = MemoEditViewModel(model: model, mode: mode)
    }
}

// MARK: - セットアップ

private extension MemoEditViewController {
    func setUpUI() {
        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        view.addGestureRecognizer(backgroundTap)
        
        guard case .replacing(let memo) = viewModel.mode else { return }
        titleTextField.text = memo.title
        textView.text = memo.text
        imageView.image = memo.image
    }
    
    
    func setUpViewModel() {
        let completionTrigger = completeButton.rx.tap.asObservable()
            .flatMap { _ -> Observable<Void> in
                return .just(())
            }
        
        let input = MemoEditViewModel.Input(
            title: titleTextField.rx.text.orEmpty.asDriver(),
            text: textView.rx.text.asDriver(),
            image: imageView.rx.image,
            completionTrigger: completionTrigger
        )
        
        let output = viewModel.transform(input: input)
        output.canTapComplete
            .drive(completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        output.completionStatus
            .subscribe { [weak self] event in
                switch event {
                case .next, .completed:
                    self?.dismiss(animated: true)
                    self?.delegate?.presentedControllerWillDismiss()
                case .error(let error): print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
}
