//
//  AppDelegate.swift
//  Demo
//
//  Created by Ernesto Rivera on 7/2/20.
//  Copyright © 2020 Applikey Solutions. All rights reserved.
//

import UIKit
import PandoraPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let player = PandoraPlayer.configure(withPaths: ["RAINDOWN_15", "pop"])
        self.window = UIWindow()
        self.window?.rootViewController = player
        self.window?.makeKeyAndVisible()

        return true
    }

}

