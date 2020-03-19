//
//  BookEditViewController.swift
//  WithBook
//
//  Created by shintykt on 2020/02/25.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

struct BookEditViewControllerFactory {
    private init() {}
    static func create(for mode: BookEditMode) -> BookEditViewController {
        let viewController = R.storyboard.bookEditViewController().instantiateInitialViewController() as! BookEditViewController
        viewController.inject(mode)
        return viewController
    }
}

final class BookEditViewController: UIViewController {
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var authorTextField: UITextField!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var selectImageButton: UIButton!
    @IBOutlet private weak var completeButton: UIButton!
    
    private var viewModel: BookEditViewModel!
    private let disposeBag = DisposeBag()
    
    weak var delegate: PresentedControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
    
    fileprivate func inject(_ mode: BookEditMode) {
        viewModel = BookEditViewModel(model: BookEditModel(), mode: mode)
    }
}

// MARK: - セットアップ

private extension BookEditViewController {
    func setUpUI() {
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: nil)
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        cancelButton.rx.tap
            .subscribe { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        view.addGestureRecognizer(backgroundTap)
        
        guard case .replacing(let book) = viewModel.mode else { return }
        titleTextField.text = book.title
        authorTextField.text = book.author
        imageView.image = book.image
    }
    
    func setUpViewModel() {
        let completionTrigger = completeButton.rx.tap.asObservable()
            .flatMap { _ -> Observable<Void> in
                return .just(())
            }
        
        let input = BookEditViewModel.Input(
            title: titleTextField.rx.text.orEmpty.asDriver(),
            author: authorTextField.rx.text.asDriver(),
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
