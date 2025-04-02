//
//  ReleafApp.swift
//  Releaf
//
//  Created by Micheal Jiang on 31/03/2025.
//

import SwiftUI
import SwiftData

@main
struct ReleafApp: App {
    let container: ModelContainer
    @State private var isLoggedIn = false
    
    init() {
        do {
            container = try ModelContainer(for: SearchHistory.self)
        } catch {
            fatalError("Failed to initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
            } else {
                LoginView()
                    .onDisappear {
                        isLoggedIn = true
                    }
            }
        }
        .modelContainer(container)
    }
}
