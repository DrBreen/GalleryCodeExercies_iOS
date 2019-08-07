//
//  AppDelegate.swift
//  GalleryExerciseApp
//
//  Created by Alexander Leontev on 03/08/2019.
//  Copyright © 2019 Alexander Leontev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var rootComponent: RootComponent!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window!.rootViewController = UINavigationController()
        rootComponent = RootComponentAssembly(parent: nil).assemble()
        window!.makeKeyAndVisible()
        
        //start the application
        rootComponent.router.go(to: .gallery, animated: false)
 
        return true
    }


}

