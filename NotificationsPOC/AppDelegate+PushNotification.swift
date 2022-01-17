//
//  AppDelegate+PushNotification.swift
//  NotificationsPOC
//
//  Created by Hesham Gamal on 12/01/2022.
//

import UIKit
import Firebase
import FirebaseMessaging
import os.log

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        os_log(.info, "did Register For Remote Notifiations with FCM Token %@", fcmToken)
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        os_log(.info, "Device Token: %@", token)
    }
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    }

    // Running When user click on the notification itself.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        os_log(.info, "gcm message Id %@", userInfo["gcm.message_id"] as? String ?? "")
        os_log(.info, "didReceive response User Info %@", userInfo)
        
        completionHandler()
    }

    // Running When app is opened and a notification is recieved.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        os_log(.info, "gcm message Id %@", userInfo["gcm.message_id"] as? String ?? "")
        os_log(.info, "did Receive Remote Notification User Info %@", userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
//    // In Case the user opened the app , we will show him the notification normally.
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        let userInfo = notification.request.content.userInfo as NSDictionary
//        os_log(.info, "will Present notification with %@", userInfo)
//        completionHandler([.alert, .badge, .sound])
//    }
}


/*
 POC:
 - user should have internet connection.
 - notification will be triggered if the user clicked on it if the app is in the background or terminated.
 - delay should happened.
*/
