//
//  ViewImageScreenViewController.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CropViewController

class ViewImageViewController: UIViewController,
    ViewImageScreenViewProtocol,
    UIScrollViewDelegate,
CropViewControllerDelegate {
    
    //views
    private let commentTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = NSLocalizedString("Comment...", comment: "Comment...")
        return textField
    }()
    
    private let saveCommentButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Save", comment: "Save"), for: .normal)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = false
        activityIndicator.color = .darkGray
        return activityIndicator
    }()
    
    private lazy var fullScreenActivityIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.backgroundColor = .white
        view.isHidden = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    //presenter
    private let viewImageScreenPresenter: ViewImageScreenPresenter
    
    //navigation buttons
    private var editButton: UIBarButtonItem!
    private var backButton: UIBarButtonItem!
    
    //constraints
    private var topImageConstraint: NSLayoutConstraint!
    private var bottomImageConstraint: NSLayoutConstraint!
    private var leadingImageConstraint: NSLayoutConstraint!
    private var trailingImageConstraint: NSLayoutConstraint!
    
    //reactive
    private let didCancelEditingRelay = PublishRelay<Void>()
    private let didFinishEditingRelay = PublishRelay<UIImage>()
    
    //state
    private var pendingMessage: String?
    
    init(viewImageScreenPresenter: ViewImageScreenPresenter) {
        self.viewImageScreenPresenter = viewImageScreenPresenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildView()
        buildNavigationBar()
        
        viewImageScreenPresenter.viewImageScreenView = self
    }
    
    private func buildView() {
        view.backgroundColor = .white
        
        view.addSubview(commentTextField)
        view.addSubview(saveCommentButton)
        
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.addSubview(imageView)
        
        saveCommentButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        saveCommentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        commentTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        commentTextField.trailingAnchor.constraint(equalTo: saveCommentButton.leadingAnchor).isActive = true
        commentTextField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor).isActive = true
        
        leadingImageConstraint = scrollView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        trailingImageConstraint = scrollView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        topImageConstraint = scrollView.topAnchor.constraint(equalTo: imageView.topAnchor)
        bottomImageConstraint = scrollView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        
        NSLayoutConstraint.activate([bottomImageConstraint, topImageConstraint, leadingImageConstraint, trailingImageConstraint])
        
        view.addSubview(fullScreenActivityIndicator)
        NSLayoutConstraint.activate([
            fullScreenActivityIndicator.widthAnchor.constraint(equalTo: view.widthAnchor),
            fullScreenActivityIndicator.heightAnchor.constraint(equalTo: view.heightAnchor),
            fullScreenActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fullScreenActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    private func buildNavigationBar() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.hidesBackButton = true
        
        self.title = "Image viewer".localized
        
        backButton = UIBarButtonItem(image: UIImage(named: "Back".localized), style: .done, target: nil, action: nil)
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
        
        editButton = UIBarButtonItem(title: "Edit".localized, style: .plain, target: nil, action: nil)
        editButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        topImageConstraint.constant = -yOffset
        bottomImageConstraint.constant = -yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        leadingImageConstraint.constant = -xOffset
        trailingImageConstraint.constant = -xOffset
        
        view.layoutIfNeeded()
    }
    
    // MARK: ViewImageScreenViewProtocol
    func set(image: UIImage) {
        imageView.image = image
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let widthScale = view.bounds.width / imageView.bounds.width
        let heightScale = view.bounds.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func set(editing: Bool) {
        if editing {
            guard let image = imageView.image else {
                return
            }
            
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            present(cropViewController, animated: true, completion: nil)
        } else {
            if let cropViewController = presentedViewController as? CropViewController {
                cropViewController.dismiss(animated: true, completion: {
                    if let pendingMessage = self.pendingMessage {
                        self.pendingMessage = nil
                        
                        self.show(message: pendingMessage)
                    }
                })
            }
        }
    }
    
    func didRequestToLeave() -> ControlEvent<Void> {
        return backButton.rx.tap
    }
    
    func didRequestToEdit() -> ControlEvent<Void> {
        return editButton.rx.tap
    }
    
    func didFinishEditing() -> ControlEvent<UIImage> {
        return ControlEvent(events: didFinishEditingRelay.asObservable())
    }
    
    func didCancelEditing() -> ControlEvent<Void> {
        return ControlEvent(events: didCancelEditingRelay.asObservable())
    }
    
    func setActivityIndicator(visible: Bool) {
        if visible {
            activityIndicator.startAnimating()
            view.bringSubviewToFront(fullScreenActivityIndicator)
            fullScreenActivityIndicator.isHidden = false
        } else {
            fullScreenActivityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func show(message: String) {
        guard presentedViewController == nil else {
            pendingMessage = message
            return
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func set(comment: String?) {
        commentTextField.text = comment
    }
    
    func didRequestToSaveComment() -> ControlEvent<String?> {
        return ControlEvent(events: saveCommentButton.rx.tap.map { [unowned self] in
            self.commentTextField.text
        })
    }
    
    // MARK: CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: {
            if cancelled {
                self.didCancelEditingRelay.accept(())
            }
        })
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.didFinishEditingRelay.accept(image)
    }
}
