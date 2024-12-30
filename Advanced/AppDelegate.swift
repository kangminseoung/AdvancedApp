//
//  AppDelegate.swift
//  Advanced
//
//  Created by 강민성 on 12/26/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: SearchViewController())
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }

}

