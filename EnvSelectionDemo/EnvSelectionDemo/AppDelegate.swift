//
//  AppDelegate.swift
//  EnvSelectionDemo
//
//  Created by Gavril Tonev on 9.07.19.
//  Copyright © 2019 Gavril Tonev. All rights reserved.
//

import UIKit

enum Envs: String, CaseIterable, EnvironmentRepresentable {
    case production = "https://production.server.com/"
    case staging = "https://staging.server.com/"
    case development = "https://development.server.com"
    case testing = "https://10.0.1.1/"
    case edge = "edge.server.com"
    
    var environmentTitle: String {
        return rawValue
    }
}

enum NonStringEnvs: Int, CaseIterable, EnvironmentRepresentable {
    case production
    case staging
    case development
    case testing
    case edge
    
    static let endpoints = [
        "https://production.server.com/",
        "https://staging.server.com/",
        "https://development.server.com",
        "https://10.0.1.1/",
        "edge.server.com"
    ]
    
    var endpoint: String {
        guard rawValue < NonStringEnvs.endpoints.count else { return "" }
        return NonStringEnvs.endpoints[rawValue]
    }
    
    var environmentTitle: String {
        return endpoint
    }
}

var ACTIVE_ENVIRONMENT = NonStringEnvs.production.environmentTitle

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let envChanger = EnvironmentChangerController(envs: Envs.self, buttonConfiguration: .image(UIImage(named: "AppIcon")!)) { selectedEnvironment in
            ACTIVE_ENVIRONMENT = selectedEnvironment.rawValue

            print(ACTIVE_ENVIRONMENT)
        }
        
        ACTIVE_ENVIRONMENT = envChanger.getSavedEnvironment()
        
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

