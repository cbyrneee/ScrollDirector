//
//  MainView.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("This app will set the scroll direction to `normal` when a mouse is connected, and `natural` when disconnected.")

            if !NotificationManager.shared.permissionGranted {
                Label(title: {
                    Text("Notification permission denied.")
                }) {
                    Image(systemName: "bell.slash.fill")
                }
                    .foregroundColor(.red)
            }
        }
            .padding()
    }
}
