//
//  ScrollDirectorApp.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import SwiftUI

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

