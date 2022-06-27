//
//  SettingsView.swift
//  ScrollDirector
//
//  Created by Conor Byrne on 27/06/2022.
//

import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                Link("View project on GitHub", destination: URL(string: "https://github.com/cbyrneee/ScrollDirector")!)
            }
        }
    }
}

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general
    }
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
        }
    }
}
