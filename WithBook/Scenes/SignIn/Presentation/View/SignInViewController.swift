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

final class SignInViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
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
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
            email: emailTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            signInTap: signInButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        
        output.canTapSignIn
            .drive(signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.signInResult
            .drive(onNext: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    let bookListViewController = R.storyboard.bookList().instantiateInitialViewController()!
                    self.navigationController?.pushViewController(bookListViewController, animated: true)
                case .failure(.invalidIdAndPassword):
                    let alert = UIAlertController(title: "メールアドレスまたはパスワードが違います", message: nil, preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "閉じる", style: .default)
                    alert.addAction(closeAction)
                    self.present(alert, animated: true)
                }
            })
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
