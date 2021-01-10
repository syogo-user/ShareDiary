//
//  AppDelegate.swift
//  ShareDiary
//
//  Created by 小野寺祥吾 on 2020/02/21.
//  Copyright © 2020 syogo-user. All rights reserved.
//

import UIKit
import Firebase
import SlideMenuControllerSwift

//import FirebaseMessaging
//import UserNotifications
//

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //SVProgressHUDを使用するための設定
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //スライダー設定
        let tabBarController = TabBarController.init(nibName: "TabBarController", bundle: nil)
        let leftViewController = LeftViewController.init(nibName: "LeftViewController", bundle: nil)
        let slideMenuController = SlideMenuController(mainViewController:tabBarController as UIViewController, leftMenuViewController: leftViewController)
        self.window?.rootViewController = slideMenuController
//        self.window?.makeKeyAndVisible()
        FirebaseApp.configure()
        
        self.window?.makeKeyAndVisible()
        //スプラッシュ画面の時間を2秒に設定
        sleep(2)
        
//        if #available (iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
        return true
    }
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        // Print message ID.
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//
//        // Print full message.
//        print(userInfo)
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // Print message ID.
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//
//        // Print full message.
//        print(userInfo)
//
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
//
//
//
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    
    
}
//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//   func userNotificationCenter(_ center: UNUserNotificationCenter,
//                               willPresent notification: UNNotification,
//                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//       let userInfo = notification.request.content.userInfo
//
//       if let messageID = userInfo["gcm.message_id"] {
//           print("Message ID: \(messageID)")
//       }
//
//       print(userInfo)
//
//       completionHandler([])
//   }
//
//   func userNotificationCenter(_ center: UNUserNotificationCenter,
//                               didReceive response: UNNotificationResponse,
//                               withCompletionHandler completionHandler: @escaping () -> Void) {
//       let userInfo = response.notification.request.content.userInfo
//       if let messageID = userInfo["gcm.message_id"] {
//           print("Message ID: \(messageID)")
//       }
//
//       print(userInfo)
//
//       completionHandler()
//   }
//}

