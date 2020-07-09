//
//  Notifications.swift
//  Nugget
//
//  Created by Ana Hidalgo de la Vega on 13/06/2020.
//  Copyright © 2020 ana. All rights reserved.
// Inspired by https://medium.com/quick-code/local-notifications-with-swift-4-b32e7ad93c2

import Foundation
import UserNotifications
import UIKit
import CoreData

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    let dateToString = DateToString()
    
    func notificationRequest() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func removePendingNotifications(id: UUID) {
        let uuidString = id.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuidString])
    }
    
    func scheduleNotification(id: UUID, date: Date, body: String, frequency: String, image: Data? = nil) {
        
        let convertedDate = dateToString.dateToString(date: date)
        let frequencyToMonths = ["Some time in 3 to 9 months": 5, "9 months": 9, "3 months": 3, "6 months": 6, "1 year": 12, "7 seconds (demo)": 7]
        
        let uuidString = id.uuidString
        
        let content = UNMutableNotificationContent()
        content.title = "Saved on \(convertedDate)"
        content.body = body
        content.badge = 1
        content.categoryIdentifier = "test"
        
        content.sound = .default
        content.userInfo = ["notificationID": uuidString]
        
        func createUNNotificationAttachment(identifier: String, image: Data? = nil, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
            let fileManager = FileManager.default
            let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
            let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
            if let data = image {
                do {
                    let uiImage = UIImage(data: data)
                    try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
                    let imageFileIdentifier = uuidString + ".png"
                    let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
                    let imageData = UIImage.pngData(uiImage!)
                    try imageData()?.write(to: fileURL)
                    let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: nil)
                    return imageAttachment
                }
                catch {
                    print("Yeah nice try")
                }
            }
            return nil
        }
        
        if let data = image {
            if let attachment = createUNNotificationAttachment(identifier: uuidString, image: data, options: nil) {
                content.attachments = [attachment]
            }
        }
        
        if frequency == "7 seconds (demo)" {
            let timeInterval = Double(frequencyToMonths[frequency]!)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
        else if frequency == "Some time in 3 to 9 months" {
            // Between 3 to 9 months
            let timeInterval = Double.random(in: 7776000.0 ..< 23328000.0)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            print(timeInterval)
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
        else {
            let timeInterval = 2592000.0 * Double(frequencyToMonths[frequency]!)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
            //  trigger.nextTriggerDate()
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
        print("notification was scheduled")
        
    }
    
    // MARK: Handle notification
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
//      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change your delay here
        DispatchQueue.main.async {
            
            let userInfo = response.notification.request.content.userInfo
            
            let id = userInfo["notificationID"] as! String
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = storyboard.instantiateViewController(withIdentifier: "NewNuggetViewController") as! NewNuggetViewController
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let request: NSFetchRequest<Nugget> = Nugget.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try context.fetch(request)
                vc.newNugget = results[0]
            }
            catch {
                print("Error fetching data, \(error)")
            }
            
            if let topVC = UIApplication.getTopViewController() {
                topVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
        completionHandler()
    }
    
}

// Taken from https://stackoverflow.com/questions/57568312/how-to-redirect-to-a-particular-viewcontroller-on-notification-click

public extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}










//        let date = Date(timeIntervalSinceNow: 5)
//        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)



//                Never managed to show info message if user says No to notifications
//                let infoMessage = UIAlertController(title: ":(", message: "You can always enable notifications from Nugget from Settings > Notifications > Nugget", preferredStyle: .alert)
//                infoMessage.addAction(UIAlertAction(title: "Ok", style: .default))
//                self.present(infoMessage, animated: true)


//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // Play sound and show alert to the user
//        completionHandler([.alert,.sound])
//        print("willPresent method called")
//    }
