//
//  AppDelegate.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 11/01/2022.
//

import UIKit

/// GLOBAL VARIABLE CREATED
var appDelegate: AppDelegate {
    return (UIApplication.shared.delegate as! AppDelegate)
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        let username = defaults.value(forKey: "username")
        if username != nil {
            goToTaskListPage()
        }
        return true
    }
    
    // To Change root vc to login (call when logout)
    func goToLoginPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    // To Change root vc to main task page (call when login)
    func goToTaskListPage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TaskListNavigation") as! UINavigationController
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    
    
}

