//
//  ScrollDirectorApp.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import SwiftUI
import UserNotifications

@main
struct ScrollDirectorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private let iokitThread = Thread(target: IOKitManager.shared, selector: #selector(IOKitManager.shared.listen), object: nil)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        iokitThread.start()
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
              print("Permission granted: \(granted)")
            }
        
        IOKitManager.shared.onConnection = { device in
            switch device.type {
            case .mouse:
                self.notification(connected: true, direction: "normal")
                setSwipeScrollDirection(false)
                break
            case .trackpad:
                self.notification(connected: true, direction: "natural")
                setSwipeScrollDirection(true)
                break
            }
        }
        
        IOKitManager.shared.onDisconnection = { device in
            switch device.type {
            case .mouse:
                self.notification(connected: false ,direction: "natural")
                setSwipeScrollDirection(true)
                break
            case .trackpad:
                self.notification(connected: false, direction: "normal")
                setSwipeScrollDirection(false)
                break
            }
        }
    }
    
    func notification(connected: Bool, direction: String) {
        let content = UNMutableNotificationContent()
        content.title = "Mouse \(connected ? "connected" : "disconnected")"
        content.body = "Setting scrolling to \(direction)."
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
