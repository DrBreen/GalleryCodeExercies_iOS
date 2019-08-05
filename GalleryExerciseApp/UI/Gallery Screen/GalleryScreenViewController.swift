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

class GalleryScreenViewController: UIViewController, GalleryScreenViewProtocol {
 
    private let galleryScreenPresenter: GalleryScreenPresenter
    
    init(galleryScreenPresenter: GalleryScreenPresenter) {
        self.galleryScreenPresenter = galleryScreenPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .themeColor
        navigationController?.navigationBar.isTranslucent = false
        title = "Gallery"
        
        galleryScreenPresenter.galleryScreenView = self
    }
    
    var updates = 0
    
    func set(pictures: [GalleryImage]) {
        updates += 1
    }
    
    func show(loadingMode: GalleryScreenLoadingMode) {
        
    }
    
    func show(error: String) {
        let alert = UIAlertController(title: "Error".localized, message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func reachedScreenBottom() -> Signal<Void> {
        //TODO: implement
        return Observable.never().asSignal(onErrorJustReturn: Void())
    }
    
    func didTapUploadImage() -> Signal<Void> {
        //TODO: implement
        return Observable.never().asSignal(onErrorJustReturn: Void())
    }
    
    func didTapImage() -> Signal<GalleryImage> {
        //TODO: implement
        return Observable.never().asSignal(onErrorJustReturn: GalleryImage(id: "", image: nil, showPlaceholder: false))
    }
    
}
