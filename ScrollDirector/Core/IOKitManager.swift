//
//  IOKitManager.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import Foundation
import IOKit

final class IOKitManager {
    public static let shared = IOKitManager()
    
    public var onConnection: ((DeviceInformation) -> ())? = nil
    public var onDisconnection: ((DeviceInformation) -> ())? = nil

    private init() {
    }
    
    /**
     Starts listening for the connection of new HID devices
     */
    @objc func listen() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
        guard let devicesDictionary: NSDictionary = IOServiceMatching(kIOHIDDeviceKey) else {
            return
        }
        
        // Specify that we want generic desktop mouses (also includes trackpads)
        devicesDictionary.setValue(kHIDPage_GenericDesktop, forKey: kIOHIDDeviceUsagePageKey)
        devicesDictionary.setValue(kHIDUsage_GD_Mouse, forKey: kIOHIDDeviceUsageKey)
        IOHIDManagerSetDeviceMatching(manager, devicesDictionary as CFDictionary)
        
        let connectCallback: IOHIDDeviceCallback = { context, result, sender, device in
            IOKitManager.shared.onConnect(device: device)
        }
        
        let disconnectCallback: IOHIDDeviceCallback = { context, result, sender, device in
            IOKitManager.shared.onDisconnect(device: device)
        }
        
        IOHIDManagerRegisterDeviceMatchingCallback(manager, connectCallback, nil)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, disconnectCallback, nil)
        
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
        RunLoop.current.run()
    }
    
    private func getDeviceInformation(device: IOHIDDevice) -> DeviceInformation? {
        // This is the device's name. (e.g. 'Apple Internal Keyboard / Trackpad')
        guard let productKey = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String else {
            return nil
        }
        
        // This is the device's key specifying its inteded use. (e.g. 2 = kHIDUsage_GD_Mouse)
        guard let primaryUsageKey = IOHIDDeviceGetProperty(device, kIOHIDPrimaryUsageKey as CFString) as? Int else {
            return nil
        }
        
        let isExternalMouse = primaryUsageKey == kHIDUsage_GD_Mouse && !productKey.lowercased().contains("trackpad")
        return DeviceInformation(name: productKey, type: isExternalMouse ? .mouse : .trackpad)
    }
    
    private func onConnect(device: IOHIDDevice) {
        guard let information = getDeviceInformation(device: device) else {
            return // TODO: Error handling
        }
        
        if information.type == .mouse, let callback = self.onConnection {
            callback(information)
        }
    }

    private func onDisconnect(device: IOHIDDevice) {
        guard let information = getDeviceInformation(device: device) else {
            return // TODO: Error handling
        }

        if information.type == .mouse, let callback = self.onDisconnection {
            callback(information)
        }
    }
}
