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
        let viewController = R.storyboard.memoEdit().instantiateInitialViewController() as! MemoEditViewController
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
    
    private let viewModel = MemoEditViewModel(model: MemoEditModel())
    private let disposeBag = DisposeBag()
    
    private var book: Book!
    private var mode: MemoEditMode!
    private lazy var bookRelay = BehaviorRelay<Book>(value: book)
    private lazy var modeRelay = BehaviorRelay<MemoEditMode>(value: mode)
    private let imageRelay = PublishRelay<UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
    
    fileprivate func inject(book: Book, mode: MemoEditMode) {
        self.book = book
        self.mode = mode
    }
}

// MARK: - セットアップ

private extension MemoEditViewController {
    func setUpUI() {
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: nil)
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        cancelButton.rx.tap
            .subscribe { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        selectImageButton.rx.tap
            .subscribe { [weak self] _ in
                self?.selectImage()
            }
            .disposed(by: disposeBag)
        
        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        view.addGestureRecognizer(backgroundTap)
    }
    
    
    func setUpViewModel() {
        let input = MemoEditViewModel.Input(
            book: bookRelay.asDriver(onErrorDriveWith: .empty()),
            mode: modeRelay.asDriver(onErrorJustReturn: .adding),
            title: titleTextField.rx.text.orEmpty.asDriver(),
            text: textView.rx.text.asDriver(),
            image: imageRelay.asDriver(onErrorJustReturn: Const.defaultImage),
            completeTap: completeButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        
        output.memo
            .drive(onNext: { [weak self] memo in
                self?.titleTextField.text = memo.title
                self?.textView.text = memo.text
                self?.imageView.image = memo.image
            })
            .disposed(by: disposeBag)
        
        output.canTapComplete
            .drive(completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.completeResult
            .drive(onNext: { [weak self] event in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 画像取得

extension MemoEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func selectImage() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        imageView.image = selectedImage
        imageRelay.accept(selectedImage)
        dismiss(animated: true)
    }
}
