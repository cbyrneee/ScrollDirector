//
//  DeviceInformation.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import Foundation

enum DeviceType {
    case mouse, trackpad
}

struct DeviceInformation {
    let name: String
    let type: DeviceType
}
