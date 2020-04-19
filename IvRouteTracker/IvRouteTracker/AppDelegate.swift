//
//  AppDelegate.swift
//  IvRouteTracker
//
//  Created by Iv on 06.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: ApplicationCoordinator?
    var blind: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        GMSServices.provideAPIKey("AIzaSyDwINLfqTlumse_8WyqLpfhtIfZdbfi31I")

        if #available(iOS 13.0, *) {
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            coordinator = ApplicationCoordinator()
            coordinator?.start()
        }

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard let nc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        blind = UIViewController()
        blind?.view?.backgroundColor = .white
        nc.pushViewController(blind!, animated: true)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard
            let nc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
            let _ = blind
        else { return }
        nc.popViewController(animated: true)
    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

