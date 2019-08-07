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
        
        //base service URL
        container
            .register(URL.self, name: "baseUrlLocalhost") { _ in URL(string: "http://localhost:4555")! }
            .inObjectScope(.container)
        
        container
            .register(URL.self, name: "baseUrl") { _ in URL(string: "http://142.93.165.77:4555")! }
        
        //NetworkRequestSender implementation
        container.register(NetworkRequestSender.self) { _ in
            let sender = AlamofireNetworkRequestSender()
            sender.errorMapper = GalleryServiceErrorMapper()
            return sender
        }.inObjectScope(.container)
        
        //GalleryService implementation
        container.register(GalleryService.self) { resolver in
            let url = resolver.resolve(URL.self, name: "baseUrl")!
            let networkRequestSender = resolver.resolve(NetworkRequestSender.self)!
            
            return DefaultGalleryService(galleryServiceURL: url, networkRequestSender: networkRequestSender)
        }.inObjectScope(.container)
        
        //GalleryProtocol implementation
        container.register(GalleryProtocol.self) { resolver in
            let galleryService = resolver.resolve(GalleryService.self)!
            
            return Gallery(galleryService: galleryService)
        }.inObjectScope(.container)
        
        let rootComponent = RootComponent(parent: container)
        
        container.register(GalleryScreenFactory.self) { _ in
            return rootComponent.galleryScreenComponent
        }
        
        container.register(UploadScreenFactory.self) { _ in
            return rootComponent.uploadScreenComponent
        }
        
        container.register(ViewImageScreenFactory.self) { _ in
            return rootComponent.viewImageScreenComponent
        }
        
        container.register(RouterProtocol.self) { resolver in
            let controller = (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController as! UINavigationController
            let galleryScreenFactory = resolver.resolve(GalleryScreenFactory.self)!
            let uploadScreenFactory = resolver.resolve(UploadScreenFactory.self)!
            let viewImageScreenFactory = resolver.resolve(ViewImageScreenFactory.self)!
            return Router(navigationController: controller, galleryScreenFactory: galleryScreenFactory, uploadScreenFactory: uploadScreenFactory, viewImageScreenFactory: viewImageScreenFactory)
            }.inObjectScope(.container)
        
        
        
        return rootComponent
    }
    
}
