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
            SettingsView()
                .frame(width: 350, height: 200)
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
        
        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(showPreferences), keyEquivalent: ",")
        preferencesItem.target = self
        
        let menu = NSMenu()
        menu.addItem(menuItem)
        menu.addItem(.separator())
        menu.addItem(preferencesItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func startIOKit() {
        iokitThread.start()
        
        IOKitManager.shared.onConnection = { device in
            switch device.type {
            case .mouse:
                self.setScrollDirection(wasConnected: true, direction: .normal)
                break
            case .trackpad:
                self.setScrollDirection(wasConnected: true, direction: .natural)
                break
            }
        }
        
        IOKitManager.shared.onDisconnection = { device in
            switch device.type {
            case .mouse:
                self.setScrollDirection(wasConnected: false, direction: .natural)
                break
            case .trackpad:
                self.setScrollDirection(wasConnected: false, direction: .normal)
                break
            }
        }
    }
    
    private func notification(_ wasConnected: Bool, _ direction: ScrollDirection) {
        let content = UNMutableNotificationContent()
        content.title = "Mouse \(wasConnected ? "connected" : "disconnected")"
        content.body = "Setting scrolling to \(direction)."
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func setScrollDirection(wasConnected: Bool, direction: ScrollDirection) {
        self.notification(wasConnected, direction)
        setSwipeScrollDirection(direction == .natural)
    }
    
    @objc func showPreferences() {
        // Ultimate hax to show the nice looking preferences window
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        
        // Windows 11 reference
        for window in NSApplication.shared.windows {
            window.center()
        }
    }
}
