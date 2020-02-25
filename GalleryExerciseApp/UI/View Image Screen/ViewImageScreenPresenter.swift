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

class ViewImageScreenPresenter {
    
    private let galleryImage: GalleryImage
    private let router: RouterProtocol
    private let galleryService: GalleryService
    private let gallery: GalleryProtocol
    
    //everything reactive
    private let disposeBag = DisposeBag()
    private var viewDisposeBag = DisposeBag()
    
    init(galleryImage: GalleryImage, galleryService: GalleryService, gallery: GalleryProtocol, router: RouterProtocol) {
        self.galleryImage = galleryImage
        self.router = router
        self.galleryService = galleryService
        self.gallery = gallery
        
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
        viewImageScreenView?.set(image: galleryImage.image!)
        viewImageScreenView?.set(comment: galleryImage.comment)
        
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
        
        viewImageScreenView?.didCancelEditing()
            .subscribe(onNext: { [unowned self] in
                self.viewImageScreenView?.set(editing: false)
            }).disposed(by: viewDisposeBag)
        
        let errorHandler: (Error) -> Void = { [unowned self] (error: Error) in
            self.viewImageScreenView?.setActivityIndicator(visible: false)
            
            let message: String
            if let error = error as? GalleryServiceError {
                message = error.error
            } else if let error = error as? GeneralError {
                message = error.text
            } else {
                message = "Something went wrong, please try again".localized
            }
            
            self.viewImageScreenView?.show(message: message)
        }
        
        viewImageScreenView?.didRequestToSaveComment()
            .do(onNext: { [unowned self] _ in
                self.viewImageScreenView?.setActivityIndicator(visible: true)
            })
            .flatMapLatest { [unowned self] comment in
                self.galleryService.addComment(name: self.galleryImage.id, comment: comment)
                    .do(onError: errorHandler)
                    .catchError { _ in Single.never() }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.gallery.invalidateCache()
                self.viewImageScreenView?.setActivityIndicator(visible: false)
            }).disposed(by: viewDisposeBag)
        
        
        viewImageScreenView?.didFinishEditing()
            .do(onNext: { _ in
                self.viewImageScreenView?.set(editing: false)
                self.viewImageScreenView?.setActivityIndicator(visible: true)
            })
            .flatMap { [unowned self] image in
                self.galleryService
                    .upload(image: image, name: self.galleryImage.id)
                    .observeOn(MainScheduler.instance)
                    .do(onError: errorHandler)
                    .catchError { _ in Observable.empty() }
                    .map { response in
                        return (image: image, response: response)
                }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (image: UIImage, _: GalleryServiceUploadResponse) in
                self.gallery.invalidateCache()
                self.viewImageScreenView?.set(image: image)
                self.viewImageScreenView?.setActivityIndicator(visible: false)
            }).disposed(by: viewDisposeBag)
        
    }
    
    private func didDetachView() {
        viewDisposeBag = DisposeBag()
    }
    
}
