//
//  Notifications.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 10/11/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class Notification {
    
    public init() {
        //default
    }
    
    public func setNotification(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
            print("setNotification succeed")
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        
        
    }
    //Daily notification: notifies the user of all of the tasks scheduled for that day
    public func createDailyNotification(date: Date, tasks: [Task]) {
        let content = UNMutableNotificationContent()
        content.title = "Good Morning!"
        var message = "You have the following tasks scheduled for today: "
        for t in tasks {
            message += t.getName() + "\n"
        }
        message += "Good luck!"
        content.body = message;
        content.sound = UNNotificationSound.default()
        content.badge =  1
//        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1;
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: date.description,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print ("Wrong \(error)")
            }
            print("setNotification for \(date.description)")
        })
        print("setNotification for \(date.description) at \(date)")
    }
    
    //Task finished notification: notifies the user when task has been finished
    // -> prompts the user to reschedule or mark as complete
    // -> Should open the app at the task page
    public func createNotification(date: Date, taskName: String){
        let content = UNMutableNotificationContent()
        content.title = "Congratulation!"
        content.body = "Your task \(taskName) should be finished by now.\nIf you haven't done so, please consider reschedule it."
        content.sound = UNNotificationSound.default()
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1;
        //let date1 = Date(timeIntervalSinceNow: 8)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 , repeats: false)
        //let triggerMinituely = Calendar.current.dateComponents([.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: taskName,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print ("Wrong \(error)")
            }
            print("setNotification for \(taskName)")
        })
        print("setNotification for \(taskName) at \(date)")
    }
    
    public func createMilkNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Buy some milk"
        content.sound = UNNotificationSound.default()
        //var numRequests = 0;
//        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { requests in
//            for request in requests {
//                print(request)
//                numRequests += 1
//            }
//        })
        
        
        //let notifNumber = 1
        content.badge =  1
        let date = Date(timeIntervalSinceNow: 5)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 , repeats: false)
        //let triggerMinituely = Calendar.current.dateComponents([.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = "LocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
                print ("Wrong \(error)")
            }
            print("setNotification added1")
        })
        print("setNotification added2")
    }
}


