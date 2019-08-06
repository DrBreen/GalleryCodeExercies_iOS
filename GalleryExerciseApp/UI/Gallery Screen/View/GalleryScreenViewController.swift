//
//  GalleryScreenViewController.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DeepDiff

//TODO: empty view message
//TODO: reload after uploading
class GalleryScreenViewController: UIViewController, GalleryScreenViewProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //constants
    private static let galleryCellId = "galleryCell"
    private static let itemsPerRowCount = 5
 
    //presenter and related to it
    private let galleryScreenPresenter: GalleryScreenPresenter
    
    //gallery view and everything related to it
    private var imageDataSource = [GalleryImage]()
    private let galleryCollectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: flow)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        return view
    }()
    
    private let refreshControl = UIRefreshControl()
    
    //navigation buttons
    private var uploadImageBarButtonItem: UIBarButtonItem!
    
    //everything reactive to report back to presenter
    private let didRequestFullReloadSubject = PublishSubject<Void>()
    private let didTapImageSubject = PublishSubject<GalleryImage>()
    
    init(galleryScreenPresenter: GalleryScreenPresenter) {
        self.galleryScreenPresenter = galleryScreenPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildNavigationBar()
        buildView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        galleryScreenPresenter.galleryScreenView = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        galleryScreenPresenter.galleryScreenView = nil
    }
    
    private func buildNavigationBar() {
        uploadImageBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        uploadImageBarButtonItem.tintColor = .white
        
        navigationItem.rightBarButtonItem = uploadImageBarButtonItem
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .themeColor
        navigationController?.navigationBar.isTranslucent = false
        title = "Gallery"
    }
    
    private func buildView() {
        view.addSubview(galleryCollectionView)
        galleryCollectionView.addSubview(refreshControl)
        galleryCollectionView.backgroundColor = .white
        galleryCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        galleryCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        galleryCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        galleryCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        galleryCollectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryScreenViewController.galleryCellId)
        galleryCollectionView.dataSource = self
        galleryCollectionView.delegate = self
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryScreenViewController.galleryCellId, for: indexPath) as! GalleryCell
        cell.set(image: imageDataSource[indexPath.row])
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = collectionView.bounds.size.width / CGFloat(GalleryScreenViewController.itemsPerRowCount)
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = self.imageDataSource[indexPath.row]
        didTapImageSubject.onNext(image)
    }
    
    // MARK: GalleryScreenViewProtocol
    func set(pictures: [GalleryImage]) {
        let changes = diff(old: imageDataSource, new: pictures)
        
        galleryCollectionView.reload(changes: changes, updateData: {
            self.imageDataSource = pictures
        })
    }
    
    func show(loadingMode: GalleryScreenLoadingMode) {
        switch loadingMode {
        case .loading:
            refreshControl.beginRefreshing()
        case .none:
            refreshControl.endRefreshing()
        }
    }
    
    func show(error: String) {
        let alert = UIAlertController(title: "Error".localized, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didTapUploadImage() -> ControlEvent<Void> {
        return uploadImageBarButtonItem.rx.tap
    }
    
    func didTapImage() -> ControlEvent<GalleryImage> {
        return ControlEvent(events: didTapImageSubject)
    }
    
    func didRequestFullReload() -> ControlEvent<Void> {
        return refreshControl.rx.controlEvent(.valueChanged)
    }
}
