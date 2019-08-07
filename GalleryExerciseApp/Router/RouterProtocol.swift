//
//  RouterProtocol.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Foundation
import RxSwift

enum RouterDestination {
    typealias Id = String
    
    public static let galleryId: RouterDestination.Id = "gallery"
    public static let uploadId: RouterDestination.Id = "upload"
    public static let viewImageId: RouterDestination.Id = "viewImage"
    
    case gallery
    case upload
    case viewImage(image: GalleryImage)
    
    var id: String {
        switch self {
        case .gallery:
            return RouterDestination.galleryId
        case .upload:
            return RouterDestination.uploadId
        case .viewImage(_):
            return RouterDestination.viewImageId
        }
    }
}

protocol RouterProtocol {
    
    var validRoutes: [RouterDestination.Id: [RouterDestination.Id]] { get }
    
    var currentLocation: RouterDestination? { get }
    
    @discardableResult
    func go(to: RouterDestination, animated: Bool) -> Bool
    
    func didGoTo() -> Observable<RouterDestination>
}
