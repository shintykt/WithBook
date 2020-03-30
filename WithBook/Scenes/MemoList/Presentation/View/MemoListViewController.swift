//
//  MemoListViewController.swift
//  WithBook
//
//  Created by shintykt on 2020/03/01.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

struct MemoListViewControllerFactory {
    private init() {}
    static func create(for book: Book) -> MemoListViewController {
        let viewController = R.storyboard.memoListViewController().instantiateInitialViewController() as! MemoListViewController
        viewController.inject(book)
        return viewController
    }
}

final class MemoListViewController: UIViewController {
    private var viewModel: MemoListViewModel!
    private let disposeBag = DisposeBag()
    
    private var book: Book!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
    
    fileprivate func inject(_ book: Book) {
        viewModel = MemoListViewModel(model: MemoListModel(book: book))
        self.book = book
    }
}

// MARK: -  セットアップ

private extension MemoListViewController {
    func setUpUI() {
        title = "メモリスト"
        
        let addBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.setRightBarButton(addBarButtonItem, animated: true)
        addBarButtonItem.rx.tap
            .subscribe { [weak self] _ in
                guard let book = self?.book else { return }
                let memoEditViewController = MemoEditViewControllerFactory.create(for: book, .adding)
                memoEditViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: memoEditViewController)
                self?.present(navigationController, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func setUpViewModel() {
        let input = MemoListViewModel.Input()
        
        let output = viewModel.transform(input: input)
        output.memos
            .drive(onNext: { [weak self] memos in
                memos.forEach { [weak self] memo in
                    self?.view.subviews.filter { ($0 as? MemoView)?.id == memo.id }.forEach {
                        $0.removeFromSuperview()
                    }
                    
                    let memoView = MemoView(memo: memo)
                    let memoTap = UITapGestureRecognizer()
                    memoTap.rx.event
                        .subscribe { _ in
                            let alert = UIAlertController(title: "選択してください", message: nil, preferredStyle: .actionSheet)
                            let replaceAction = UIAlertAction(title: "メモを編集する", style: .default) { _ in
                                guard let book = self?.book else { return }
                                let memoEditViewController = MemoEditViewControllerFactory.create(for: book, .replacing(memo))
                                memoEditViewController.delegate = self
                                let navigationController = UINavigationController(rootViewController: memoEditViewController)
                                self?.present(navigationController, animated: true)
                            }
                            let removeAction = UIAlertAction(title: "メモを削除する", style: .default) { _ in
                                self?.viewModel.remove(memo)
                                memoView.removeFromSuperview()
                            }
                            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
                            [replaceAction, removeAction, cancelAction].forEach {
                                alert.addAction($0)
                            }
                            self?.present(alert, animated: true)
                        }
                        .disposed(by: self?.disposeBag ?? DisposeBag())
                    memoView.addGestureRecognizer(memoTap)
                    
                    self?.view.addSubview(memoView)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - メモ追加・編集

extension MemoListViewController: MemoEditDelegate {
    // 追加・編集が終了したらリストを更新
    func didEdit(for mode: MemoEditMode, memo: Memo) {
        switch mode {
        case .adding: viewModel.add(memo)
        case .replacing: viewModel.replace(memo)
        }
    }
}
