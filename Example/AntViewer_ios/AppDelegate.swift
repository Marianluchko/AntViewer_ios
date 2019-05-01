//
//  AppDelegate.swift
//  AntViewer_ios
//
//  Created by Mykola Vaniurskyi on 04/17/2019.
//  Copyright (c) 2019 Mykola Vaniurskyi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        generateUserName()
        return true
    }

  func generateUserName() {
    let name = UserDefaults.standard.string(forKey: "userName")
    if name == nil, let random = Array(0...100500).randomElement() {
      UserDefaults.standard.set("SuperFan\(random)", forKey: "userName")
    }
  }

}

