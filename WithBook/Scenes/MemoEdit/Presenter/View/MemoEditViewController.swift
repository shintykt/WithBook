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

protocol MemoEditDelegate: AnyObject {
    func didEdit(for mode: MemoEditMode, memo: Memo)
}

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
    
    weak var delegate: MemoEditDelegate?
    
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
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
                strongSelf.delegate?.didEdit(for: strongSelf.viewModel.mode, memo: strongSelf.viewModel.memo)
            }
            .disposed(by: disposeBag)
        
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
        let input = MemoEditViewModel.Input(
            title: titleTextField.rx.text.orEmpty.asDriver(),
            text: textView.rx.text.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        output.canTapComplete
            .drive(completeButton.rx.isEnabled)
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
        viewModel.input(selectedImage)
        dismiss(animated: true)
    }
}
