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
    
    private let viewModel = BookEditViewModel(model: BookEditModel())
    private let disposeBag = DisposeBag()
    
    private var mode: BookEditMode!
    private let modeRelay = PublishRelay<BookEditMode>()
    private let imageRelay = PublishRelay<UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
    
    fileprivate func inject(_ mode: BookEditMode) {
        self.mode = mode
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
        
        selectImageButton.rx.tap
            .subscribe { [weak self] _ in
                self?.selectImage()
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .subscribe { [weak self] event in
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
    }
    
    func setUpViewModel() {
        let input = BookEditViewModel.Input(
            mode: modeRelay.asDriver(onErrorJustReturn: .adding),
            title: titleTextField.rx.text.orEmpty.asDriver(),
            author: authorTextField.rx.text.asDriver(),
            image: imageRelay.asDriver(onErrorJustReturn: Const.defaultImage),
            completeTap: completeButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        
        output.book
            .drive(onNext: { [weak self] book in
                self?.titleTextField.text = book.title
                self?.authorTextField.text = book.author
                self?.imageView.image = book.imageData.image
            })
            .disposed(by: disposeBag)
        
        output.canTapComplete
            .drive(completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.completeResult
            .drive() // エラー処理
            .disposed(by: disposeBag)
        
        modeRelay.accept(mode)
    }
}

// MARK: - 画像取得

extension BookEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
