//
//  ViewImageScreenPresenter.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//TODO: add tests
//TODO: implement
//TODO: after editing the image, present edited version
class ViewImageScreenPresenter {
    
    private let galleryImage: GalleryImage
    private let router: RouterProtocol
    
    //everything reactive
    private let disposeBag = DisposeBag()
    private var viewDisposeBag = DisposeBag()
    
    init(galleryImage: GalleryImage, router: RouterProtocol) {
        self.galleryImage = galleryImage
        self.router = router
        
        guard galleryImage.image != nil else {
            fatalError("ViewImageScreenPresenter can not handle nil images")
        }
    }
    
    weak var viewImageScreenView: ViewImageScreenViewProtocol? {
        didSet {
            if let _ = viewImageScreenView {
                didAttachView()
            } else {
                didDetachView()
            }
        }
    }
    
    private func didAttachView() {
        viewImageScreenView?.setImage(image: galleryImage.image!)
        
        startObservingView()
    }
    
    private func startObservingView() {
        viewImageScreenView?.didRequestToLeave()
            .subscribe(onNext: { [unowned self] in
                self.router.go(to: .gallery, animated: true)
            }).disposed(by: viewDisposeBag)
        
        viewImageScreenView?.didRequestToEdit()
            .subscribe(onNext: { [unowned self] in
                self.viewImageScreenView?.set(editing: true)
            }).disposed(by: viewDisposeBag)
    }
    
    private func didDetachView() {
        viewDisposeBag = DisposeBag()
    }
    
}
