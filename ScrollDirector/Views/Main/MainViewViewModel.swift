//
//  MainViewViewModel.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import Foundation

final class MainViewViewModel : ObservableObject {
    @Published private(set) var latestDevice: DeviceInformation? = nil
    
    init() {
        IOKitManager.shared.onConnection = { device in
            DispatchQueue.main.async {
                self.latestDevice = device
            }
        }
    }
}
