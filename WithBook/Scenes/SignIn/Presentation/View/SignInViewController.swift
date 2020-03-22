//
//  SignInViewController.swift
//  WithBook
//
//  Created by shintykt on 2020/02/12.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import FirebaseAuth
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

final class SignInViewController: UIViewController {
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    
    private let viewModel = SignInViewModel(model: SignInModel())
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
}

// MARK: - セットアップ

private extension SignInViewController {
    func setUpUI() {
        title = "ログイン"
        
        idTextField.delegate = self
        
        passwordTextField.delegate = self
        
        signInButton.rx.tap
            .subscribe { [weak self] _ in
                SVProgressHUD.show()
                guard let strongSelf = self else { return }
                Auth.auth().signIn(
                    withEmail: strongSelf.idTextField.text!,
                    password: strongSelf.passwordTextField.text!
                ) { authResult, error in
                    defer { SVProgressHUD.dismiss() }
                    
                    if let error = error {
                        print(error)
                    }
                    
                    guard authResult?.user != nil else {
                        let alert = UIAlertController(title: "メールアドレスまたはパスワードが違います", message: nil, preferredStyle: .alert)
                        let closeAction = UIAlertAction(title: "閉じる", style: .default)
                        alert.addAction(closeAction)
                        strongSelf.present(alert, animated: true)
                        return
                    }
                    // TODO: uidにひもづいたBookを取得
                    let bookListViewController = R.storyboard.bookListViewController().instantiateInitialViewController()!
                    strongSelf.navigationController?.pushViewController(bookListViewController, animated: true)
                }
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
        let input = SignInViewModel.Input(
            id: idTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        output.canTapSignIn
            .drive(signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

// MARK: - テキスト入力管理

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
