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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        
        // 탭 바 컨트롤러 설정
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        
        let savedBooksVC = UINavigationController(rootViewController: SavedBooksViewController())
        savedBooksVC.tabBarItem = UITabBarItem(title: "담은 책", image: UIImage(systemName: "book"), tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [searchVC, savedBooksVC]
        tabBarController.tabBar.isHidden = true // 탭 바 표시
        
        // 윈도우 설정
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

    // Core Data 스택
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Advanced")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
