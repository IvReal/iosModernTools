//
//  NotificationService.swift
//  IvRouteTracker
//
//  Created by Iv on 05.05.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UserNotifications

class NotificationService
{
    static let instance = NotificationService()
    private init() {}
    
    func makeNotificationContent(title: String, body: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = 1
        return content
    }
        
    func makeIntervalNotificationTrigger(minutes: Double) -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            timeInterval: minutes * 60.0,
            repeats: false
        )
    }
        
    func sendNotificationRequest(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendExampleNotificationRequest() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.sendNotificationRequest(
                    id: "remind",
                    content: self.makeNotificationContent(title: "Reminder", body: "Let's continue to work with application"),
                    trigger: self.makeIntervalNotificationTrigger(minutes: 30.0))
            }
        }
    }
}
