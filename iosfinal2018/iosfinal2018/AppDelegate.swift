//
//  AppDelegate.swift
//  iosfinal2018
//
//  Created by Zachary Kimelheim on 4/10/18.
//  Copyright © 2018 Zachary Kimelheim. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      // Override point for customization after application launch.
      
      //Configure Firebase app
      FirebaseApp.configure()
//
//        //Google DSK keys given here
      GMSServices.provideAPIKey("AIzaSyDjNSgs6Wj56_wF5gvr9zlWCuVXNU-V1C8")
      GMSPlacesClient.provideAPIKey("AIzaSyDjNSgs6Wj56_wF5gvr9zlWCuVXNU-V1C8")
      
      // Check if user is authorized
      Auth.auth().addStateDidChangeListener() { auth, user in
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // If user exists perform segue
        if user == nil {
          // Access the storyboard and fetch an instance of the view controller
          let storyboard = UIStoryboard(name: "Login", bundle: nil)
          let viewController: LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
          let navigationController = UINavigationController(rootViewController: viewController)
          
          // Then push that view controller onto the navigation stack
          self.window!.rootViewController = navigationController
          self.window!.makeKeyAndVisible()
        } else {
          // Access the storyboard and fetch an instance of the view controller
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let mapVC: MapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
          let adviceVC: AdviceVC = storyboard.instantiateViewController(withIdentifier: "AdviceVC") as! AdviceVC
          let tabBarController = UITabBarController()
          let vcArray = [mapVC, adviceVC]
          tabBarController.setViewControllers(vcArray, animated: false)
          
          // Then push that view controller onto the navigation stack
          self.window!.rootViewController = tabBarController
          self.window!.makeKeyAndVisible()
        }
      }
      return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

