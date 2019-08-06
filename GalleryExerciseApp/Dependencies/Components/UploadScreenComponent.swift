//
//  UploadScreenComponent.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import Swinject

class UploadScreenComponent: Component, UploadScreenFactory {
    
    var uploadScreenViewController: UIViewController {
        return UploadScreenViewController(uploadScreenPresenter: container.resolve(UploadScreenPresenter.self)!)
    }
    
}
