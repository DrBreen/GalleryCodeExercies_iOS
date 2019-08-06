//
//  ViewImageScreenViewController.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 06/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController, ViewImageScreenViewProtocol {
    
    private let viewImageScreenPresenter: ViewImageScreenPresenter
    
    init(viewImageScreenPresenter: ViewImageScreenPresenter) {
        self.viewImageScreenPresenter = viewImageScreenPresenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
