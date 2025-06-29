//
//  githubProjApp.swift
//  githubProj
//
//  Created by Nicholas Galen on 29/06/25.
//

import SwiftUI

@main
struct githubProjApp: App {
    // setamos o nosso viewmodel para o user
    @StateObject private var userVM = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userVM)  // injetamos o viewModel para todas as views
        }
    }
}
