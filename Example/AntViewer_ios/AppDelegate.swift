//
//  AppDelegate.swift
//  AntViewer_ios
//
//  Created by Mykola Vaniurskyi on 04/17/2019.
//  Copyright (c) 2019 Mykola Vaniurskyi. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        FirebaseApp.configure()
        setupNotificationsFor(application: application)
        Messaging.messaging().delegate = self
      
      //MARK: Connect PN to Antourage Firebase app
       Messaging.messaging().retrieveFCMToken(forSenderID: "1090288296965") { (token, error) in
          //MARK: Send this token to our BE
          print("TOKEN F OR EXTERNAL BE: \(token!)")
        }
      
      //MARK: Remove PN from Antourage Firebase APP
      Messaging.messaging().deleteFCMToken(forSenderID: "1090288296965") { (error) in
        //MARK: Also do something
      }
      
        generateUserName()
        return true
    }

  func generateUserName() {
    let name = UserDefaults.standard.string(forKey: "userName")
    if name == nil, let random = Array(0...100500).randomElement() {
      UserDefaults.standard.set("SuperFan\(random)", forKey: "userName")
    }
  }
  
  func setupNotificationsFor(application: UIApplication) {
    
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: {_, _ in })
    
    application.registerForRemoteNotifications()
  }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("\(notification.request.content.userInfo)")

      completionHandler([.alert, .badge, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print("\(response.notification.request.content.userInfo)")
  }
  
}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Token: \(fcmToken)")
  }
  
}

