//
//  RootComponentAssembly.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 05/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import Swinject
import UIKit

class RootComponentAssembly: Assembly {
    
    typealias Assembled = RootComponent
    
    required init(parent: Container?) {}
    
    func assemble() -> RootComponent {
        let container = Container()
        
        container.register(RouterProtocol.self) { _ in
            let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController as! UINavigationController
            return Router(navigationController: controller)
        }
        
        //base service URL
        container.register(URL.self, name: "baseUrl") { _ in URL(string: "http://localhost:4555")! }
        
        //NetworkRequestSender implementation
        container.register(NetworkRequestSender.self) { _ in
            let sender = AlamofireNetworkRequestSender()
            sender.errorMapper = GalleryServiceErrorMapper()
            return sender
        }
        
        //GalleryService implementation
        container.register(GalleryService.self) { resolver in
            let url = resolver.resolve(URL.self, name: "baseUrl")!
            let networkRequestSender = resolver.resolve(NetworkRequestSender.self)!
            
            return DefaultGalleryService(galleryServiceURL: url, networkRequestSender: networkRequestSender)
        }
        
        //GalleryProtocol implementation
        container.register(GalleryProtocol.self) { resolver in
            let galleryService = resolver.resolve(GalleryService.self)!
            
            return Gallery(galleryService: galleryService)
        }
        
        return RootComponent(parent: container)
    }
    
}
