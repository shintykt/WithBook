//
//  BookListViewController.swift
//  WithBook
//
//  Created by shintykt on 2020/02/29.
//  Copyright © 2020 Takaya Shinto. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class BookListViewController: UICollectionViewController {
    private let cellSize = CGSize(width: 160, height: 240)
    private let spacePerRow: CGFloat = 20
    private var spacePerColumn: CGFloat {
        let totalSpace = view.frame.width - 2 * cellSize.width
        let spaceCount: CGFloat = 3
        return totalSpace / spaceCount
    }
    private var edgeInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: spacePerColumn, bottom: 0, right: spacePerColumn)
    }
    
    private lazy var dataSource: RxCollectionViewSectionedAnimatedDataSource<BookListSectionModel> = .init(
        animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .none, deleteAnimation: .fade),
        configureCell: { dataSource, collection, indexPath, item -> UICollectionViewCell in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: R.nib.bookListCell.name, for: indexPath)
            if let cell = cell as? BookListCell {
                cell.inject(item.book)
            }
            return cell
        })
    
    private let viewModel = BookListViewModel(model: BookListModel())
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModel()
    }
}

// MARK: - セットアップ

private extension BookListViewController {
    func setUpUI() {
        title = "ブックリスト"
        
        let addBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.setRightBarButton(addBarButtonItem, animated: true)
        addBarButtonItem.rx.tap
            .subscribe { [weak self] _ in
                let bookEditViewController = BookEditViewControllerFactory.create(for: .adding)
                bookEditViewController.delegate = self
                self?.present(bookEditViewController, animated: true)
            }
            .disposed(by: disposeBag)

        collectionView.dataSource = nil
        collectionView.delegate = nil
        collectionView.register(BookListCell.self, forCellWithReuseIdentifier: R.nib.bookListCell.name)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        collectionView.rx.modelSelected(BookListSectionItem.self)
            .subscribe { [weak self] event in
                guard let item = event.element else { return }
                let alert = UIAlertController(title: "選択してください", message: nil, preferredStyle: .actionSheet)
                let memoAction = UIAlertAction(title: "メモリストを見る", style: .default) { _ in
                    let memoListViewController = MemoListViewControllerFactory.create(for: item.book)
                    self?.navigationController?.pushViewController(memoListViewController, animated: true)
                }
                let replaceAction = UIAlertAction(title: "ブックを編集する", style: .default) { _ in
                    let bookEditViewController = BookEditViewControllerFactory.create(for: .replacing(item.book))
                    bookEditViewController.delegate = self
                    self?.present(bookEditViewController, animated: true)
                }
                let removeAction = UIAlertAction(title: "ブックを削除する", style: .default) { _ in
                    self?.viewModel.remove(item)
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
                [memoAction, replaceAction, removeAction, cancelAction].forEach {
                    alert.addAction($0)
                }
                self?.present(alert, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func setUpViewModel() {
        let input = BookListViewModel.Input()
        
        let output = viewModel.transform(input: input)
        output.books
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
}

// MARK: - リストレイアウト

extension BookListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacePerRow
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
}

// MARK: - モーダル管理(iOS13対応)

extension BookListViewController: PresentedControllerDelegate {
    // 追加・編集が終了したらリストを更新
    func presentedControllerWillDismiss() {
        viewModel.fetchBooks()
        collectionView.reloadData()
    }
}
