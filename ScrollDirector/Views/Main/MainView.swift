//
//  MainView.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 26/06/2022.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewViewModel()
    
    var body: some View {
        Group {
            Text("This app will set the scroll direction to `normal` when a mouse is connected, and `natural` when disconnected.")
        }
        .frame(width: 300, height: 100)
        .padding()
    }
}
