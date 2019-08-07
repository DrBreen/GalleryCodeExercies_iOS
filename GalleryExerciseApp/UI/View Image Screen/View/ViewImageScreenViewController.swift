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

//TODO: add double tap
class ViewImageViewController: UIViewController,
    ViewImageScreenViewProtocol,
    UIScrollViewDelegate,
CropViewControllerDelegate {
    
    //views
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
    }
    
    private func buildView() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        scrollView.addSubview(imageView)
        
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        leadingImageConstraint = scrollView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        trailingImageConstraint = scrollView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        topImageConstraint = scrollView.topAnchor.constraint(equalTo: imageView.topAnchor)
        bottomImageConstraint = scrollView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        
        NSLayoutConstraint.activate([bottomImageConstraint, topImageConstraint, leadingImageConstraint, trailingImageConstraint])
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewImageScreenPresenter.viewImageScreenView = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewImageScreenPresenter.viewImageScreenView = nil
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
    func setImage(image: UIImage) {
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
            present(cropViewController, animated: true, completion: nil)
        } else {
            if let cropViewController = presentedViewController as? CropViewController {
                cropViewController.dismiss(animated: true, completion: nil)
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
        //TODO: implement
        return ControlEvent(events: Observable.never())
    }
    
    func didCancelEditing() -> ControlEvent<Void> {
        //TODO: implement
        return ControlEvent(events: Observable.never())
    }
    
    func setActivityIndicator(visible: Bool) {
        //TODO: implement
    }
    
}
