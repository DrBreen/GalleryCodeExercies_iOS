//
//  UploadScreenViewController.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

//TODO: add tests
class UploadScreenViewController: UIViewController, UploadScreenViewProtocol {
    
    //presenter and everything related
    private let uploadScreenPresenter: UploadScreenPresenter
    
    //everything reactive
    private let didCancelUploadSubject = PublishSubject<Void>()
    private let didPickImageForUploadSubject = PublishSubject<UIImage>()
    private let didPickUploadModeSubject = PublishSubject<UploadMode>()
    
    init(uploadScreenPresenter: UploadScreenPresenter) {
        self.uploadScreenPresenter = uploadScreenPresenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        uploadScreenPresenter.uploadScreenView = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        uploadScreenPresenter.uploadScreenView = nil
    }
    
    private func buildView() {
        view.backgroundColor = .clear
    }
    
    // MARK: UploadScreenViewProtocol
    func showUploadModePicker() {
        let picker = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        picker.addAction(UIAlertAction(title: "Take photo".localized, style: .default, handler: { _ in
            self.didPickUploadModeSubject.onNext(.takePhoto)
        }))
        
        picker.addAction(UIAlertAction(title: "Select from gallery".localized, style: .default, handler: { _ in
            self.didPickUploadModeSubject.onNext(.pickFromGallery)
        }))
        
        picker.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
            self.didCancelUploadSubject.onNext(())
        }))
        
        present(picker, animated: true, completion: nil)
    }
    
    func setActivityIndicator(visible: Bool) {
        //TODO: implement
    }
    
    func showImagePicker(mode: UploadMode) {
        switch mode {
        case .pickFromGallery:
            showGalleryPicker()
        case .takePhoto:
            showTakePhotoPicker()
        }
    }
    
    private func showTakePhotoPicker() {
        //TODO: implement
    }
    
    private func showGalleryPicker() {
        //TODO: implement
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func show(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "OK".localized, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func didPickUploadMode() -> ControlEvent<UploadMode> {
        return ControlEvent(events: didPickUploadModeSubject)
    }
    
    func didCancelUpload() -> ControlEvent<Void> {
        return ControlEvent(events: didCancelUploadSubject)
    }
    
    func didPickImageForUpload() -> ControlEvent<UIImage> {
        //TODO: implement
        return ControlEvent(events: Observable.never())
    }
    
}
