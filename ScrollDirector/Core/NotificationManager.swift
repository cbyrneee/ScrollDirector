//
//  NotificationManager.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 27/06/2022.
//

import Foundation
import UserNotifications

final class NotificationManager {
    public static let shared = NotificationManager()

    public var permissionGranted: Bool = false

    private init() {
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            self.permissionGranted = granted
        }
    }

    func push(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}