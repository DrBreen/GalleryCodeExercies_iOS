//
//  GalleryScreenPresenter.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

//TODO: reload after uploading
class GalleryScreenPresenter {
    
    private let gallery: GalleryProtocol
    
    var galleryScreenView: GalleryScreenViewProtocol? {
        didSet {
            if let _ = galleryScreenView {
                didAttachView()
            } else {
                didDetachView()
            }
        }
    }
    
    private var viewDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    private let router: RouterProtocol
    
    init(gallery: GalleryProtocol, router: RouterProtocol) {
        self.gallery = gallery
        self.router = router
    }
    
    private func didAttachView() {
        //let's subscribe to various view events
        startObservingView()
        
        //first step is to show loading indicator
        galleryScreenView?.show(loadingMode: .loading)
        
        //now let's fetch some images
        updateImages()
    }
    
    private func updateImages() {
        gallery
            .fetchImages()
            .debounce(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] pictures in
                self.update(pictures: pictures)
            }, onError: { [unowned self] error in
                self.show(error: error)
            }).disposed(by: disposeBag)
    }
    
    private func startObservingView() {
        
        //force unwrapping because at this point it should never be nil - if it is, that means
        //that's a programming error
        let view = galleryScreenView!
        
        view
            .didTapImage()
            .subscribe(onNext: { [unowned self] image in
                self.router.go(to: .viewImage(image: image), animated: true)
            })
            .disposed(by: viewDisposeBag)
        
        view
            .didTapUploadImage()
            .subscribe(onNext: { [unowned self] in
                self.router.go(to: .upload, animated: true)
            })
            .disposed(by: viewDisposeBag)
        
        view
            .didRequestFullReload()
            .subscribe(onNext: { [unowned self] in
                self.updateImages()
            })
            .disposed(by: viewDisposeBag)
    }
    
    private func didDetachView() {
        //replace old bag, effectively disposing of everything in it
        viewDisposeBag = DisposeBag()
    }
    
    // MARK: Helpers
    private func update(pictures: [GalleryImage]) {
        //after we've got some pictures, disable loading
        galleryScreenView?.show(loadingMode: .none)
        
        galleryScreenView?.set(pictures: pictures)
    }
    
    private func show(error: Error) {
        galleryScreenView?.show(loadingMode: .none)
        
        if let error = error as? GalleryServiceError {
            galleryScreenView?.show(error: error.error)
        } else {
            galleryScreenView?.show(error: "Sorry, failed to load images".localized)
        }
    }
}
