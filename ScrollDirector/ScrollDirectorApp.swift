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
        Settings {
            Text("Coming soon")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private let iokitThread = Thread(target: IOKitManager.shared, selector: #selector(IOKitManager.shared.listen), object: nil)
    
    private var statusItem: NSStatusItem!
        
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission granted: \(granted)")
        }
    
        self.setupMenu()
        self.startIOKit()
    }
    
    private func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "computermouse.fill", accessibilityDescription: "ScrollDirection")
        }
        
        let mainView = NSHostingView(rootView: MainView())
        mainView.frame = NSRect(x: 0, y: 0, width: 250, height: 100)
        
        let menuItem = NSMenuItem()
        menuItem.view = mainView
        
        let menu = NSMenu()
        menu.addItem(menuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func startIOKit() {
        iokitThread.start()
        
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
    
    private func notification(connected: Bool, direction: String) {
        let content = UNMutableNotificationContent()
        content.title = "Mouse \(connected ? "connected" : "disconnected")"
        content.body = "Setting scrolling to \(direction)."
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
