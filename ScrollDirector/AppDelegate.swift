//
// Created by Conor Byrne on 27/06/2022.
//

import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private let iokitThread = Thread(target: IOKitManager.shared, selector: #selector(IOKitManager.shared.listen), object: nil)
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationManager.shared.requestPermission()
        self.setupMenu()
        self.startIOKit()
    }

    private func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "computermouse.fill", accessibilityDescription: "ScrollDirection")
        }

        let mainView = NSHostingView(rootView: MainView())
        mainView.frame = NSRect(x: 0, y: 0, width: 250, height: 150)

        let mainViewItem = NSMenuItem()
        mainViewItem.view = mainView

        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(showPreferencesWindow), keyEquivalent: ",")
        preferencesItem.target = self

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let menu = NSMenu()
        menu.addItem(mainViewItem)
        menu.addItem(.separator())
        menu.addItem(preferencesItem)
        menu.addItem(quitItem)

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

    private func setScrollDirection(wasConnected: Bool, direction: ScrollDirection) {
        setSwipeScrollDirection(direction == .natural)

        NotificationManager.shared.push(
            title: "Mouse was \(wasConnected ? "connected" : "disconnected")",
            body: "Setting scrolling to \(direction)."
        )
    }

    @objc private func showPreferencesWindow() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)

        for window in NSApplication.shared.windows {
            window.center()
        }
    }
}